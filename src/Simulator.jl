include("MarketDB.jl")
include("portfoliostats.jl")
include("Portfolios.jl")
include("PortfolioDB.jl")
include("Strategies.jl")

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
    strategy.processInfo(simulator.mdb, curr_date, strategy.pdb,     strategy.portfolio, simulator.transaction_fee)
    # add dividends
    addDividend(curr_date, simulator.mdb, strategy.portfolio)
    # compute portfolio stats
    value = evaluateValue(strategy.portfolio, curr_date, simulator.mdb)
    cumulative_return = computeCumulativeReturn(strategy.portfolio, curr_date, strategy.pdb, simulator.mdb)
    annual_return = computeAnnualizedReturn(strategy.portfolio, curr_date, strategy.pdb, simulator.mdb)
    volatility = computeVolatility(strategy.portfolio, curr_date, strategy.pdb)
    riskreward = computeRiskReward(strategy.portfolio, curr_date,0.02, strategy.pdb)
    # write day statistics to the portfolio database
    writePortfolio(strategy.pdb, curr_date, strategy.portfolio, volatility, riskreward, value, annual_return, cumulative_return)
end

"""
    run(simulator)
"""
function runSim(simulator::Simulator)
    all_dates = @from i in simulator.mdb.data begin
    @where i.date >= simulator.start_date && i.date <= simulator.end_date
    @select i.date
    @collect
    end
    all_dates = unique(all_dates)
    for date in all_dates
        for strategy in simulator.strategies
            update(simulator, strategy, date)
        end
    end
end
