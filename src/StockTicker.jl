module StockTickerMod

    #using FinData
    #import datasrc
    #temporary until datasrc is figured out
    function validTicker(exchange::String, symbol::String)
        return true
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
        function StockTicker(exchange, symbol)
            # Check whether the ticker exists in the data source
            tickerAvailable = validTicker(exchange, symbol)
            # If not return an error
            if !tickerAvailable
                error("Information for this ticker is not available.")
            else
                return new(exchange, symbol)
            end
        end
    end

    export StockTicker

end