include("./Portfolios.jl")
include("./Tickers.jl")

"""
    Strategy(processInfo, portfolio)

This is the structure for a Strategy object. It must have a function that dictates what action(s) to take on a portfolio when a new day of information is available. The processInfo function must be designed such that it takes in the following arguments:
    processInfo(marketData::MarketDB, date::Date, portfolioData::PortfolioDB, portfolio::Portfolio, transfee::Float64)
"""
struct Strategy
    processInfo::AnonymousFunction
    portfolio::Portfolios
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
    return
end
