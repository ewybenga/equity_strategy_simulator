module Ticker

    using FinData
    export datasrc

    """
        Ticker(name)

    The Ticker object contains the exchange and symbol. It checks
    that the data for that equity is available in the current
    datasource. This is checked using datasrc.validTicker(), and
    a datasrc must be defined in the scope of the Ticker.

    exchange: String of the exchange the ticker is traded on (ie "NYSE")
    symbol: String of the ticker name (ie "GOOG")
    """

    struct Ticker
        exchange::String
        symbol::String
        function Ticker(exchange, symbol)
            # Check whether the ticker exists in the data source
            tickerAvailable = datasrc.validTicker()
            # If not return an error
            if !tickerAvailable
                error("Information for this ticker is not available.")
            else
                return Ticker(exchange, symbol)
            end
        end
    end


end