include("./MarketDB.jl")
include("./Portfolios.jl")

export PortfolioDB, writePortfolio, getPortfolioState

"""
	PortfolioDB()

The PortfolioDB stores the state of the portfolio and associated statistics at each date during the simulation. Each record contains the date, value, capital, volatility, riskreward, annual return, cumulative return, and the number of shares of each stock available in the MarketDB.
"""

mutable struct PortfolioDB
    data::DataFrame
    function PortfolioDB(m::MarketDB)
        # initialize a new DataFrame to hold temporal portfolio data
        data = DataFrame(date=Date[], value=Float64[], capital=Float64[], volatility=Float64[], riskreward=Float64[], return_annual= Float64[], return_cumulative=Float64[])
        # create columns for each ticker available in MarketDB
        stocks = Dict()
        for i in unique(m.data[:ticker])
            stocks[i] = Float64[]
        end
        stockDF=DataFrame(stocks)
        stockDF.date=Date[]
        # join the columns so the DataFrame first has statistics, then holdings
        data=join(data, stockDF, on=:date)
        return new(data)
    end
end

"""
    writePortfolio(pdb, date, portfolio, volatility, riskreward, value, return_annual, return_cumulative)

Writes a new row in the portfolioDB for a given date
"""
function writePortfolio(pdb::PortfolioDB, date::Date, portfolio::Portfolio, volatility::Float64, riskreward::Float64, value::Float64, return_annual::Float64, return_cumulative::Float64)
    newrow = Dict()
    # add count of each stock
    stockCounts=Dict()
    for i in portfolio.holdings
        stockCounts[i[1].symbol] = i[2]
    end
    # add portfolio statistics
    newrow["date"]=date
    newrow["value"]=value
    newrow["capital"]=portfolio.capital
    newrow["volatility"]=volatility
    newrow["riskreward"]=riskreward
    newrow["return_annual"]=return_annual
    newrow["return_cumulative"]=return_cumulative
    stocks = Dict()
    for i in setdiff(string.(names(pdb.data)), keys(newrow))
        if i in keys(stockCounts)
            stocks[i] = stockCounts[i]
        else
            stocks[i] = 0.
        end
    end
    # create ordered row (same order as PortfolioDB)
    stocks = sort(stocks)
    st = DataFrame(stocks)
    st.date=date
    nr = DataFrame(newrow)
    nr = nr[[:date, :value, :capital, :volatility, :riskreward, :return_annual, :return_cumulative]]
    writablerow = join(nr,st,on=:date)
    # write do database
    append!(pdb.data,writablerow)
end

"""
    getPortfolioState(pdb, date)

gets the row in the portfolioDB containing the state of the portfolio and associated statistics on a given date
"""
function getPortfolioState(pdb::PortfolioDB, date::Date)
    res = @from i in pdb.data begin
            @where i.date == date
            @select i
            @collect DataFrame
        end
    if size(res)[1]==0
        return missing
    end
    return res
end
