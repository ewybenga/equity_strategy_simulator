using Dates
using Query
include("./Tickers.jl")
include("./MarketData.jl")


export Portfolio, query, buy, sell

  """
      query(data, date, ticker, column)

  Purpose: Returns the value of a column of the ticker at the given date

  data: MarketDB object of data for the simulation
  date: Date you want the price of the ticker at
  ticker: A Ticker object containing the exchange and symbol of the ticker
  column: the column name to query
  """
  function query(data::MarketDB, date::Date, ticker::Ticker, column::Symbol)
      #error handling whether date is outside the ticker start and end range
      if date<ticker.start_date || date>ticker.end_date
        throw(BoundsError("The requested date for this ticker isn't in the data source"))
      end
      #query db
      res = @from i in data.data begin
              @where i.ticker == ticker.symbol && i.primexch == ticker.exchange && i.date == date
              @select i[column]
              @collect
          end
      #return value
      return res
  end

  """
    query(data, date_start, date_end, ticker, column)

  Purpose: Returns the value of a column of the ticker at the given date

  data: MarketDB object of data for the simulation
  date: Date you want the price of the ticker at
  ticker: A Ticker object containing the exchange and symbol of the ticker
  column: the column name to query
  """
  function query(data::MarketDB, date_start::Date, date_end::Date, ticker::Ticker, column::Symbol)
      #error handling whether date is outside the ticker start and end range
      if date_start<ticker.start_date || date_end>ticker.end_date
        throw(BoundsError("The requested date for this ticker isn't in the data source"))
      end
      #query db
      res = @from i in data.data begin
              @where i.ticker == ticker.symbol && i.primexch == ticker.exchange && i.date >= date_start && i.date < date_end
              @select i[column]
              @collect
          end
      #return value
      return res
  end

  """
    query(data, date, ticker, columns)

  Purpose: Returns the value of a column of the ticker at the given date

  data: MarketDB object of data for the simulation
  date: Date you want the price of the ticker at
  ticker: A Ticker object containing the exchange and symbol of the ticker
  columns: the list of column names to query. If list is [:All], query all.
  """
  function query(data::MarketDB, date::Date, ticker::Ticker, columns::Array{Symbol,1})
      # error handling whether date is outside the ticker start and end range
      if date<ticker.start_date || date>ticker.end_date
        throw(BoundsError("The requested date for this ticker isn't in the data source"))
      end
      # query db
      res = @from i in data.data begin
              @where i.ticker == ticker.symbol && i.primexch == ticker.exchange && i.date == date
              @select i
              @collect DataFrame
          end
      # narrow down columns if requested
      if !(columns==[:All])
        res = res[1, columns]
      end
      # return value
      return res
  end


  """
    query(data, date_start, date_end, ticker, columns)

  Purpose: Returns the value of a column of the ticker at the given date

  data: MarketDB object of data for the simulation
  date: Date you want the price of the ticker at
  ticker: A Ticker object containing the exchange and symbol of the ticker
  columns: the list of column names to query. If list is [:All], query all.
  """
  function query(data, date_start::Date, date_end::Date, ticker::Ticker, columns::Array{Symbol,1})
      #error handling whether date is outside the ticker start and end range
      if date_start<ticker.start_date || date_end>ticker.end_date
        throw(BoundsError("The requested date for this ticker isn't in the data source"))
      end
      #query db
      res = @from i in data.data begin
              @where i.ticker == ticker.symbol && i.primexch == ticker.exchange && i.date >= date_start && i.date < date_end
              @select i
              @collect DataFrame
          end
      # narrow down columns if requested
      if !(columns==[:All])
        res = res[columns]
      end
      #return value
      return res
  end



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
function buy(portfolio::Portfolio, stock::Ticker, numshares::Float64, date::Date, transfee:: Float32, data::MarketDB)
  # get the value of the stock at the given date
  try
    price = query(data, date, stock, :prc)
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
function sell(portfolio::Portfolio, stock::Ticker, numshares::Float64, date::Date, transfee:: Float32, data::MarketDB)
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
    price = query(data, date, stock, :prc)
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


