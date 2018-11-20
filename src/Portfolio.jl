module PortfolioMod
  using Dates
  include("./StockTicker.jl")
  using .StockTickerMod

  """
      Portfolio(holdings, capital)

  The Portfolio object contains a dictionary of holdings (ticker:number of shares) as well as the amount of liquid capital available

  """
  mutable struct Portfolio
      holdings::Dict{StockTicker, Float64}
      capital::Float64
  end



  """
    PortfolioState(portfolio, start_date, current_date)

  The PortfolioState object contains a portfolio as well as the start_date of the period, used to compute
  information such as returns over time, and the current_date. The PortfolioState represents the portfolio's
  holdings at a given place in time.
  """
  struct PortfolioState
    currPortfolio::Portfolio
    start_date::Dates.Date
    curr_date::Dates.Date
  end

  """
    buy(portfolio, stock, numshares, date, transfee, data)

  Buys numshares shares of the given stock by querying the data for the price and trading that amount of capital for holdings in the portfolio
  """
  function buy(portfolio::Portfolio, stock::StockTicker, numshares::Float64, date::Date, transfee:: Float32, data::MarketDB)
    # get the value of the stock at the given date
    try
      price = query(data, date, stock)
    catch e
      # if the value cannot be found print the error statement and return the
      # portfolio unchanged
      print("Could not find data for the ticker ", stock, " on the date ", date)
      print(e)
      return 0, :None
    end
    # check that the portfolio has enough capital to buy this amount of shares
    if portfolio.capital < (numshares * totalPrice - transfee)
      # if it does not, buy as many shares as possible with current capital
      numshares = floor((portfolio.capital - transfee)/price)
    end
    if numshares>0
      # subtract capital spent
      portfolio.capital -= (numshares * price + transfee)
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
  function sell(portfolio::Portfolio, stock::StockTicker, numshares::Float64, date::Date, transfee:: Float32, data::MarketDB)
    # check that the portfolio has shares of this stock
    if haskey(portfolio.holdings, stock) == false
       return 0, :None
    end
    # check that the portfolio has as many shares as are requested to be sold
    if portfolio.holdings[stock] < numshares
      numshares = portfolio.holdings[stock]
    end
    # get the value of the stock at the given date
    try
      price = query(data, date, stock)
    catch e
      # if the value cannot be found print the error statement and return the
      # portfolio unchanged
      print("Could not find data for the ticker ", stock, " on the date ", date)
      print(e)
      return 0, :None
    end
    # subtract shares from portfolio
    if numshares == portfolio.holdings[stock]
      delete!(portfolio.holdings, stock)
    else
      portfolio.holdings[stock] -= numshares
    end
    # add capital from selling the shares, minus the transaction fee
    portfolio.capital += (numshares * price - transfee)
    return numshares, price
  end


export Portfolio
export PortfolioState

end
