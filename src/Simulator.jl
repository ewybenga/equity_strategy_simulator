include("MarketDB.jl")
include("portfoliostats.jl")
include("Portfolios.jl")
include("PortfolioDB.jl")
include("Strategies.jl")
include("simulationplots.jl")
using Plots

export run

"""
    Simulator(mdb, start_date, end_date, strategies)

Simulator struct holds all the information necessary to run a simulation of a portfolio strategy over a period of time
"""
struct Simulator
    mdb::MarketDB
    start_date::Date
    end_date::Date
    strategies::Array{Strategy,1}
    transaction_fee::Float64
end

"""
    update(simulator, strategy, curr_date)

Update the state of a strategy in a simulator on a given date. This includes updating the days allocations, adding dividends to the portfolio, computing portfoliostats, and writing the portfolio state and statistics to the portfolioDB
"""
function update(simulator::Simulator, strategy::Strategy, curr_date::Date)
    # update day's allocations
    strategy.processInfo(simulator.mdb, curr_date, strategy.pdb,     strategy.portfolio, simulator.transaction_fee, strategy.otherData)
    # add dividends
    addDividend(curr_date, simulator.mdb, strategy.portfolio)
    # compute portfolio stats
    value = evaluateValue(strategy.portfolio, curr_date, simulator.mdb)
    cumulative_return = computeCumulativeReturn(strategy.portfolio, curr_date, strategy.pdb, simulator.mdb)
    annual_return = computeAnnualizedReturn(strategy.portfolio, curr_date, strategy.pdb, simulator.mdb)
    volatility = computeVolatility(annual_return, strategy.pdb)
    riskreward = computeRiskReward(annual_return, volatility)
    # write day statistics to the portfolio database
    writePortfolio(strategy.pdb, curr_date, strategy.portfolio, volatility, riskreward, value, annual_return, cumulative_return)
    return value, cumulative_return, annual_return, volatility, riskreward
end

"""
    run(simulator)
"""
function runSim(simulator::Simulator, plot::Bool=false)
    all_dates = @from i in simulator.mdb.data begin
    @where i.date >= simulator.start_date && i.date <= simulator.end_date
    @select i.date
    @collect
    end
    all_dates = unique(all_dates)
    if plot
        # set up plot
        gr(show=:ijulia)
        start = minimum(all_dates)
        xlim = [Dates.value(start-Day(2)), Dates.value(maximum(all_dates))]
        stratNames = [s.name for s in simulator.strategies]
        stratNames = reshape(stratNames, (1, size(stratNames)[1]))
        initialDate = (start-Day(2)):Day(1):(start-Day(1))
        initialData = [zeros(2) for i in 1:length(simulator.strategies)]
        plt = plot(initialDate, initialData, title="Cumulative Return over Time", xlabel="Date", ylabel="Cumulative Return", label=stratNames, xlims=xlim)
    end
    for date in all_dates
        for strategy in simulator.strategies
            update(simulator, strategy, date)
        end
        if plot
            # add data to plot
            annRets = [s.pdb.data[:return_cumulative][length(s.pdb.data[:return_cumulative])] for s in simulator.strategies]
            push!(plt, Dates.value(date), annRets)
            display(plt)
        end
    end
end
