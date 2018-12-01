include("./MarketDB.jl")
include("./Portfolios.jl")

export PortfolioDB

"""
	PortfolioDB()

The
"""

mutable struct PortfolioDB
    data::DataFrame
    function PortfolioDB(m::MarketDB)
        # initialize a new DataFrame to hold temporal portfolio data
        data = DataFrame(date=Date[], value=Float64[], capital=Float64[], volatility=Float64[], riskreward=Float64[], return_annual= Float64[], return_cumulative=Float64[])

        stocks = Dict()
        for i in unique(m.data[:ticker])
            stocks[i] = Float64[]
        end
        stockDF=DataFrame(stocks)
        stockDF.date=Date[]
        data=join(data, stockDF, on=:date)

        return new(data)
    end
end
