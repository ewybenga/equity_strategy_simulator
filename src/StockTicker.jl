module StockTickerMod
    using Dates
    #using MarketDB

    #temporary until datasrc is figured out
    function validTicker(data::String, exchange::String, symbol::String)
        return true, Date(2000, 1, 1), Date(2018, 1, 1)
    end


    """
        StockTicker(name)

    The StockTicker object contains the exchange and symbol. It checks
    that the data for that equity is available in the current
    datasource. This is checked using datasrc.validTicker(), and
    a datasrc must be defined in the scope of the StockTicker.

    exchange: String of the exchange the ticker is traded on (ie "NYSE")
    symbol: String of the ticker name (ie "GOOG")
    """
    struct StockTicker
        exchange::String
        symbol::String
        start_date::Date
        end_date:: Date
        function StockTicker(data, exchange, symbol)
            # Check whether the ticker exists in the data source
            tickerAvailable, start_date, end_date = validTicker(data, exchange, symbol)
            # If not return an error
            if !tickerAvailable
                error("Information for this ticker is not available.")
            else
                return new(exchange, symbol, start_date, end_date)
            end
        end
    end

    export StockTicker

end
