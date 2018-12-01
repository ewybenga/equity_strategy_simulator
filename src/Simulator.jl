include("MarketDB.jl")
include("portfoliostats.jl")
include("Portfolios.jl")
include("PortfolioDB.jl.jl")


function writePortfolio(pdb::PortfolioDB, date::Date, portfolio::Portfolio, volatility::Float64, riskreward::Float64, value::Float64, return_annual::Float64, return_cumulative::Float64)
    newrow = Dict()
    stockCounts=Dict()
    for i in portfolio.holdings
        stockCounts[i[1].symbol] = i[2]
    end

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
    stocks = sort(stocks)
    st = DataFrame(stocks)
    st.date=date

    nr = DataFrame(newrow)
    nr = nr[[:date, :value, :capital, :volatility, :riskreward, :return_annual, :return_cumulative]]

    writablerow = join(nr,st,on=:date)
    append!(pdb.data,writablerow)
end
