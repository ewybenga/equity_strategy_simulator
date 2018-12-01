include("./MarketDB.jl")
include("./Portfolios.jl")

export PortfolioDB

"""
	PortfolioDB()

The
"""


function write(date::Date, portfolio::Portfolio, volatility::Float64, riskreward::Float64, value::Float64, )
    println(date)
end

mutable struct PortfolioDB
    data::DataFrame
    function PortfolioDB(m::MarketDB)
        # initialize a new DataFrame to hold temporal portfolio data
        stocks = unique!(m.data[:ticker])
        data = DataFrame(date=Date[], value=Float64[], capital=Float64[], volatility=Float64[], riskreward=Float64[], returns=Float64[])
        for i in stocks
            data.i = Float64[]
        end

        return new(data)
    end
end
