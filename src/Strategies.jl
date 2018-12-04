include("./Portfolios.jl")
include("./Tickers.jl")
include("./PortfolioDB.jl")

"""
    Strategy(name, processInfo, portfolio, mdb)

This is the structure for a Strategy object. It must have a function that dictates what action(s) to take on a portfolio when a new day of information is available. The processInfo function must be designed such that it takes in the following arguments:
    processInfo(marketData::MarketDB, date::Date, portfolioData::PortfolioDB, portfolio::Portfolio, transfee::Float64)
"""
mutable struct Strategy
    name::String
    processInfo::Function
    portfolio::Portfolio
    otherData::Dict
    pdb::PortfolioDB
    function Strategy(name::String, processInfo::Function, portfolio::Portfolio, mdb::MarketDB)
        pdb = PortfolioDB(mdb)
        otherData = Dict()
        return new(name, processInfo, portfolio, otherData, pdb)
    end

end

"""
    ExampleStrategy1()

Defines a strategy to hold google and buy google if it has the cash
"""
function Example1(marketData, date, portfolioData, portfolio, transfee)
    goog = Ticker(marketData, "Q", "GOOG")
    price = queryMarketDB(marketData, date, goog, :prc)
    if ismissing(price)
        return
    else
        numShares = floor(portfolio.capital/price[1].value)
        buy(portfolio, goog, numShares, date, transfee, marketData)
    end
    return
end

"""
    ExampleStrategy2()

Defines a strategy to hold google and buy google if it has the cash
"""
function Example2(marketData, date, portfolioData, portfolio, transfee)
    netflix = Ticker(marketData, "Q", "NFLX")
    price = queryMarketDB(marketData, date, netflix, :prc)
    if ismissing(price)
        return
    else
        numShares = floor(portfolio.capital/price[1].value)
        buy(portfolio, netflix, numShares, date, transfee, marketData)
    end
    return
end

"""
    SandPBaseline()

Defines a strategy to hold the S&P 500 and buy it if it has cash
"""
function SandP(marketData, date, portfolioData, portfolio, transfee)
    sp = Ticker(marketData, "SP", "SP500")
    price = queryMarketDB(marketData, date, sp, :prc)
    if ismissing(price)
        return
    else
        numShares = floor(portfolio.capital/price[1].value)
        buy(portfolio, sp, numShares, date, transfee, marketData)
    end
    return
end
