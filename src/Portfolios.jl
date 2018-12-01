using Dates
using Query
include("./Tickers.jl")
include("./queryfunctions.jl")


export Portfolio, buy, sell


"""
    Portfolio(holdings, capital)

The Portfolio object contains a dictionary of holdings (ticker:number of shares) as well as the amount of liquid capital available

"""
mutable struct Portfolio
    holdings::Dict{Ticker, Float64}
    capital::Float64
end


"""
  buy(portfolio, stock, numshares, date, transfee, data)

Buys numshares shares of the given stock by querying the data for the price and trading that amount of capital for holdings in the portfolio
"""
function buy(portfolio::Portfolio, stock::Ticker, numshares::Float64, date::Date, transfee:: Float64, data::MarketDB)
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
    portfolio.capital = round(portfolio.capital - (numshares * price + transfee), digits=2)
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
  sell(portfolio, stock, numshares, date, transfee, data)

Sells numshares shares of the given stock by querying the data for the price and trading that amount of shares in the portfolio for the amount of capital it's worth
"""
function sell(portfolio::Portfolio, stock::Ticker, numshares::Float64, date::Date, transfee:: Float64, data::MarketDB)
  # check that the portfolio has shares of this stock
  if haskey(portfolio.holdings, stock) == false
    print("Shorting is not allowed, cannot sell ", stock," on date ", date)
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
  # add capital from selling the shares, minus the transaction fee
  portfolio.capital += round((numshares * price - transfee), digits=2)
  return numshares, price
end
