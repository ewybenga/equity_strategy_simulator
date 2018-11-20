#import JuliaDB or TimeSeries or DataFrames
include("./StockTicker.jl")
using .StockTickerMod

"""
    validTicker(data, exchange, symbol)

Purpose: The data source has a function that finds whether
a given exchange-symbol is in the database, and if so what
the start and end dates that the ticker appears in the DB

data: MarketDB datasource of the simulation
exchange: String of the exchange the ticker is traded on (ie "NYSE")
symbol: String of the ticker name (ie "GOOG")
"""
function validTicker(data::MarketDB, exchange::String, symbol::String)
    #temporary until data is set up
    return true, Date(2000, 1, 1), Date(2018, 1, 1)
end


"""
    query(data, date, ticker)

Purpose: Returns the price of the ticker at the given date

data: MarketDB object of data for the simulation
date: Date you want the price of the ticker at
ticker: A StockTicker object containing the exchange and symbol of the ticker
"""
function query(data::MarketDB, date::Date, ticker::StockTicker)
    #error handling whether date is outside the ticker start and end range
        #if out of bounds throw BoundsError
    #query db
    #return value
    return 10
end

"""
    queryRange(data, start_date, end_date, ticker)

Purpose: Returns the price of the ticker at the given date

data: MarketDB object of data for the simulation
start_date: Date you want the price of the ticker starting at
end_date: Date you want the price of the ticker ending at
ticker: A StockTicker object containing the exchange and symbol of the ticker
"""
function queryRange(data::MarketDB, start_date::Date, end_date::Date,  ticker::StockTicker)
    #error handling whether date is outside the ticker start and end range
        #if out of bounds throw BoundsError
    #query db
    #return value
    #temporary solution
    numdays = abs(Days.value(end_date-start_date))
    return fill(10, numdays)
end
