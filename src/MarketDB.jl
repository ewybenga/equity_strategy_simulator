#import JuliaDB or TimeSeries or DataFrames


'''
    validTicker(exchange, symbol)

Purpose: The data source has a function that finds whether
a given exchange-symbol is in the database, and if so what
the start and end dates that the ticker appears in the DB

exchange: String of the exchange the ticker is traded on (ie "NYSE")
symbol: String of the ticker name (ie "GOOG")
'''
function validTicker(exchange::String, symbol::String)
    #temporary until data is set up
    return true, Date(2000, 1, 1), Date(2018, 1, 1)
end
