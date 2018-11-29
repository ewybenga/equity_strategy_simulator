
module MarketDBQueryMod
    include("./StockTicker.jl")
    using .StockTickerMod
    include("./MarketDB.jl")
    using .MarketDBMod
    using Dates

    """
        query(data, date, ticker)

    Purpose: Returns the price of the ticker at the given date

    data: MarketDB object of data for the simulation
    date: Date you want the price of the ticker at
    ticker: A StockTicker object containing the exchange and symbol of the ticker
    """
    function query(data::MarketDB, date::Date, ticker::StockTicker, column::String)
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
    function queryRange(data::MarketDB, start_date::Date, end_date::Date,  ticker::StockTicker, column::String)
        #error handling whether date is outside the ticker start and end range
            #if out of bounds throw BoundsError
        #query db
        #return value
        #temporary solution
        numdays = abs(Days.value(end_date-start_date))
        return fill(10, numdays)
    end

    export query, queryRange

end