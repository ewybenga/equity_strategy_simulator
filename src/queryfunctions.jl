using Dates
include("./Tickers.jl")
include("./MarketDB.jl")

export queryMarketDB

"""
  queryMarketDB(data, date, ticker, column)

Purpose: Returns the value of a column of the ticker at the given date

data: MarketDB object of data for the simulation
date: Date you want the price of the ticker at
ticker: A Ticker object containing the exchange and symbol of the ticker
column: the column name to query
"""
function queryMarketDB(data::MarketDB, date::Date, ticker::Ticker, column::Symbol)
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
  # check if empty results set
  if size(res)[1] == 0
    return missing
  end
  #return value
  return res
end

"""
queryMarketDB(data, date_start, date_end, ticker, column)

Purpose: Returns the value of a column of the ticker at the given date

data: MarketDB object of data for the simulation
date: Date you want the price of the ticker at
ticker: A Ticker object containing the exchange and symbol of the ticker
column: the column name to query
"""
function queryMarketDB(data::MarketDB, date_start::Date, date_end::Date, ticker::Ticker, column::Symbol)
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
  # check if empty results set
  if size(res)[1] == 0
    return missing
  end
  #return value
  return res
end

"""
queryMarketDB(data, date, ticker, columns)

Purpose: Returns the value of a column of the ticker at the given date

data: MarketDB object of data for the simulation
date: Date you want the price of the ticker at
ticker: A Ticker object containing the exchange and symbol of the ticker
columns: the list of column names to query. If list is [:All], query all.
"""
function queryMarketDB(data::MarketDB, date::Date, ticker::Ticker, columns::Array{Symbol,1})
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
  # check if empty results set
  if size(res)[1] == 0
    return missing
  end
  # narrow down columns if requested
  if !(columns==[:All])
    res = res[1, columns]
  end
  # return value
  return res
end


"""
queryMarketDB(data, date_start, date_end, ticker, columns)

Purpose: Returns the value of a column of the ticker at the given date

data: MarketDB object of data for the simulation
date: Date you want the price of the ticker at
ticker: A Ticker object containing the exchange and symbol of the ticker
columns: the list of column names to query. If list is [:All], query all.
"""
function queryMarketDB(data, date_start::Date, date_end::Date, ticker::Ticker, columns::Array{Symbol,1})
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
  # check if empty results set
  if size(res)[1] == 0
    return missing
  end
  # narrow down columns if requested
  if !(columns==[:All])
    res = res[columns]
  end
  #return value
  return res
end
