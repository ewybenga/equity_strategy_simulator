module MarketDBMod
    using DelimitedFiles
    using DataFrames
    using Query
    using Dates

    """
        replaceEmpty(dataItem)

    returns val if the data item is an empty string, otherwise returns the original data item
    """
    function replaceEmpty(dataItem, val)
        if dataItem==""
            return val
        else
            return dataItem
        end
    end

    """
        processData(filepath)

    This function takes in a filepath (assumes CRSP data) and returns a DataFrame with the following columns and data types:

          ____________________________________________________________________
    NAME | date   |    ticker   |    primexch    |   divamt    |    prc      |
         |________|_____________|________________|_____________|_____________|
    TYPE | Date   |    String   |     String     |  Float64    | U{Missing,  |
         |________|_____________|________________|_____________|___Float64}__|

    """
    function processData(filepath)
        # read data using DelimitedFiles
        data = readdlm(filepath, ',')
        # read this into a DataFrame
        df = DataFrame(data[2:size(data)[1], :])
        # change column names to symbols of first row
        names!(df, [Symbol(lowercase(i)) for i in data[1, :]])
        # change dates from Strings to formatted Dates
        df[:date] = Dates.Date.(string.(df[:date]), "yyyymmdd")
        # replace empty data items with 0 for dividend amount
        df[:divamt] = replaceEmpty.(df[:divamt], 0.)
        # change type of primexch and ticker to String
        df[:primexch] = string.(df[:primexch])
        df[:ticker] = string.(df[:ticker])
        # replace empty prices with missing
        df[:prc] = replaceEmpty.(df[:prc], missing)
        # delete unnecessary columns
        extraCols = [n for n in names(df) if !any(x->x==n, [:date, :ticker, :divamt, :primexch, :prc])]
        delete!(df, extraCols)
        return df
    end



    """
        MarketDB(data)

    This structure is a wrapper for the data. It assumes use of the CRSP data from WRDS. To use a different data source, replace the processData function to output a DataFrame with the same columns and data types.
    """
    struct MarketDB
        data::DataFrame
        function MarketDB(filepath::String)
            return new(processData(filepath))
        end
    end


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

    export MarketDB, validTicker

end

