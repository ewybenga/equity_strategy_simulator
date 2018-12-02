using Dates
using Query
include("./Tickers.jl")
include("./queryfunctions.jl")


export Portfolio, buy, sell, placeOrder, addDividend


"""
    Portfolio(holdings, capital)

The Portfolio object contains a dictionary of holdings (ticker:number of shares) as well as the amount of liquid capital available

"""
mutable struct Portfolio
    holdings::Dict{Ticker, Float64}
    capital::Float64
end

"""
overwrite show for dict of ticker=>float64
"""
function Base.show(io::IO, holdings::Dict{Ticker, Float64})
  linelen=30
  dashline = "|"*'-'^(linelen-2)*"|\n"
  s = '-'^linelen*'\n'
  l = "|holdings:"
  l = l*' '^(linelen-1-length(l))*"|\n"
  s=s*l
  for h in holdings
      l = "|   "
      t = h[1]
      l = l*string(t.symbol)*"("*t.exchange*"): "*string(h[2])*" shares"
      l = l*' '^(linelen-length(l)-1)*"|\n"
      s = s*l
  end
  s = s*dashline
    print(io, s)
end

"""
overwriting show for Portfolio to show pretty version
"""
function Base.show(io::IO, p::Portfolio)
  linelen = 30
  s = '-'^linelen*'\n'
  c = "|capital: "*string(round(p.capital, digits=2))
  c = c*' '^(linelen-1-length(c))*"|\n"
  s = s*c
  dashline = "|"*'-'^(linelen-2)*"|\n"
  s=s*dashline
  l = "|holdings:"
  l = l*' '^(linelen-1-length(l))*"|\n"
  s=s*l
  for h in p.holdings
      l = "|   "
      t = h[1]
      l = l*string(t.symbol)*"("*t.exchange*"): "*string(h[2])*" shares"
      l = l*' '^(linelen-length(l)-1)*"|\n"
      s = s*l
  end
  s = s*dashline
  print(io, s)
end


"""
  buy(portfolio, stock, numshares, date, transfee, data, applyTransfee=true)

Buys numshares shares of the given stock by querying the data for the price and trading that amount of capital for holdings in the portfolio
"""
function buy(portfolio::Portfolio, stock::Ticker, numshares::Float64, date::Date, transfee:: Float64, data::MarketDB, applyTransfee::Bool=true)
  # get the value of the stock at the given date
  price = queryMarketDB(data, date, stock, :prc)
  # if the value cannot be found print the error statement and return the portfolio unchanged
  if ismissing(price)
    println("Could not find data for the ticker ", stock, " on the date ", date)
    return 0, :None
  end
  # check that the portfolio has enough capital to buy this amount of shares
  price = price[1].value
  if portfolio.capital < (numshares * price + transfee)
    # if it does not, buy as many shares as possible with current capital
    numshares = floor((portfolio.capital - transfee)/price)
  end
  if numshares>0
    # subtract capital spent
    if applyTransfee
      portfolio.capital = round(portfolio.capital - (numshares * price + transfee), digits=2)
    else
      portfolio.capital = round(portfolio.capital - (numshares * price), digits=2)
    end
    # add shares to portfolio
    if haskey(portfolio.holdings, stock)
      portfolio.holdings[stock] += numshares
    else
      portfolio.holdings[stock] = numshares
    end
  end
  # return the number of shares bought and the price it was bought at
  return numshares, price
end

"""
  sell(portfolio, stock, numshares, date, transfee, data, applyTransfee=true)

Sells numshares shares of the given stock by querying the data for the price and trading that amount of shares in the portfolio for the amount of capital it's worth
"""
function sell(portfolio::Portfolio, stock::Ticker, numshares::Float64, date::Date, transfee:: Float64, data::MarketDB, applyTransfee::Bool=true)
  # check that the portfolio has shares of this stock
  if haskey(portfolio.holdings, stock) == false
    println("Shorting is not allowed, cannot sell ", stock," on date ", date)
     return 0, :None
  end
  # check that the portfolio has as many shares as are requested to be sold
  if portfolio.holdings[stock] < numshares
    numshares = portfolio.holdings[stock]
  end
  # get the value of the stock at the given date
  price = queryMarketDB(data, date, stock, :prc)
  # if the value cannot be found print the error statement and return the portfolio unchanged
  if ismissing(price)
    println("Could not find data for the ticker ", stock, " on the date ", date)
    return 0, :None
  end
  price = price[1].value
  # subtract shares from portfolio
  if numshares == portfolio.holdings[stock]
    delete!(portfolio.holdings, stock)
  else
    portfolio.holdings[stock] -= numshares
  end
  # add capital from selling the shares, minus the transaction fee if it should be applied now
  if applyTransfee
    portfolio.capital += round((numshares * price - transfee), digits=2)
  else
    portfolio.capital += round((numshares * price), digits=2)
  end
  return numshares, price
end

"""
  placeOrder(type, transfee, date, data, portfolio, orders)

Places an order of type buy or sell with a transaction fee on a given date to the portfolio. The orders will consist of a dictionary of ticker:numshares
"""
function placeOrder(type::Symbol, transfee::Float64, date::Date, data::MarketDB, portfolio::Portfolio, orders::Dict{Ticker, Float64})
  #dictionary to store results of order attempts
  res = Dict{Ticker, Tuple}()
  #for each stock in the order
  for stock in keys(orders)
    numshares = orders[stock]
    # buy or sell
    if type==:buy
      curres = buy(portfolio, stock, numshares, date, transfee, data, false)
    elseif type==:sell
      curres = sell(portfolio, stock, numshares, date, transfee, data, false)
    else
      println("Neither buy nor sell was selected")
      return res
    end
    res[stock] = curres
  end
  # now subtract transaction fee
  portfolio.capital -= transfee
  return res
end

"""
  addDividend(date, data, portfolio)

Calculates the accumulated dividends accross all holdings in a profile and adds that amount to the profile's capital
"""
function addDividend(date::Date, data::MarketDB, portfolio::Portfolio)
    for holding in portfolio.holdings
        i = queryMarketDB(data, date, holding[1], :divamt)
        if i == 0.
            continue
        else
            portfolio.capital += i[1]*holding[2]
        end
    end
end
