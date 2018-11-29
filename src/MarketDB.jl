

module MarketDBMod

    """
        MarketDB(data)

    This structure is a wrapper for whatever data source is used in the simulation for market data. 

    TODO:: Fill in more details here

    """
    struct MarketDB
        dataSrc::Any
        test::Int64
        """TODO: Add a function to check that the dataSrc is a valid format"""
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

