using Dates
using Query
include("./MarketDB.jl")


export Ticker

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
    datesValid = @from i in data.data begin
                    @where i.ticker==symbol && i.primexch==exchange
                    @select i.date
                    @collect
                end
    if length(datesValid) == 0
        return false, missing, missing
    else
        return true, minimum(datesValid), maximum(datesValid)
    end
end


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
    start_date::Date
    end_date:: Date
    function Ticker(data::MarketDB, exchange::String, symbol::String)
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
