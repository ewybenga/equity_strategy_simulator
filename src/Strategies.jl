include("./Portfolios.jl")
include("./Tickers.jl")
include("./PortfolioDB.jl")

"""
    Strategy(name, processInfo, portfolio, mdb)

This is the structure for a Strategy object. It must have a function that dictates what action(s) to take on a portfolio when a new day of information is available. The processInfo function must be designed such that it takes in the following arguments:
    processInfo(marketData::MarketDB, date::Date, portfolioData::PortfolioDB, portfolio::Portfolio, transfee::Float64, otherData::Dict)
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
function Example1(marketData, date, portfolioData, portfolio, transfee, otherData)
    goog = Ticker(marketData, "Q", "MSFT")
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
function Example2(marketData, date, portfolioData, portfolio, transfee, otherData)
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
    buyDropSellGain()

defines a strategy that buys all the google it has the cash for if the sum of daily returns for the last 5 days is less than -5% and sells off half of the number of shares of google it has if the sum of daily returns for the last 5 days is greater than 5%
"""
function buyDropSellGain(marketData, date, portfolioData, portfolio, transfee, otherData::Dict)
    function computeDailyReturnPerShare(portfolio::Portfolio, date::Date, mdb::MarketDB, ticker::Ticker)
        if date <= mdb.data[:date][1]
            return 0
        end
        # find ticker trade price on the last trading day
        p_yesterday = getMostRecentPrice(mdb, date-Day(1), ticker)
        # find current price
        p_current = getMostRecentPrice(mdb, date, ticker)
        # compute annualized return
        return (p_current/p_yesterday) - 1.
    end

    goog = Ticker(marketData, "Q", "MSFT")

    returns = Float64[]
    for date in date-Day(7):Day(1):date
        append!(returns, computeDailyReturnPerShare(portfolio, date, marketData, goog))
    end
    sumval = 0.
    sumval = sum(returns)
    if sumval <= -0.05
        price = queryMarketDB(marketData, date, goog, :prc)
        if ismissing(price)
            return
        else
            numShares = floor(portfolio.capital/price[1].value)
            buy(portfolio, goog, numShares, date, transfee, marketData)
        end
    elseif sumval >= 0.07
        price = queryMarketDB(marketData, date, goog, :prc)
        if ismissing(price)
            return
        else
            if length(portfolio.holdings) == 0
                return
            else
            sell(portfolio, goog, floor(portfolio.holdings[goog]/2.0), date, transfee, marketData)
            end
        end
    end

    return
end

"""
    SandPBaseline()

Defines a strategy to hold the S&P 500 and buy it if it has cash
"""
function SandP(marketData, date, portfolioData, portfolio, transfee, otherData)
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
