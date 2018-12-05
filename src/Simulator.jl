include("MarketDB.jl")
include("portfoliostats.jl")
include("Portfolios.jl")
include("PortfolioDB.jl")
include("Strategies.jl")
include("simulationplots.jl")
using Plots
using Colors
using CSV

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
    return [value, cumulative_return, annual_return, volatility, riskreward]
end

"""
    runSim(simulator, live_plot=false)

This is the main function that runs the simulation for each strategy in the simulator over the date range specified in the simulator. If live_plot is set to true live visualizations are shown as the simulation progresses. The portfolio database for each strategy is written out at the end of the simulation, and the updated state of the Simulator is returned
"""
function runSim(simulator::Simulator, live_plot::Bool=false)
    #get date range to plot over
    all_dates = @from i in simulator.mdb.data begin
    @where i.date >= simulator.start_date && i.date <= simulator.end_date
    @select i.date
    @collect
    end
    all_dates = unique(all_dates)
    if live_plot
        # set up plot
        start = minimum(all_dates)
        xlim = [Dates.value(start-Day(2)), Dates.value(maximum(all_dates))]
        stratNames = [s.name for s in simulator.strategies]
        stratNames = reshape(stratNames, (1, size(stratNames)[1]))
        initialDate = (start-Day(2)):Day(1):(start-Day(1))
        initialData = [zeros(2) for i in 1:length(simulator.strategies)]
        pltRet = plot(initialDate, initialData, title="Cumulative Return over Time", xlabel="Date", ylabel="Cumulative Return", label=stratNames, xlims=xlim, legend=:false)
        pltRR = plot(initialDate, initialData, title="Risk Reward over Time", xlabel="Date", ylabel="Risk Reward", label=stratNames, xlims=xlim, legend=:false)
        stratLegend = plot(initialDate, initialData, labels=stratNames, grid=false, showaxis=false, xlims=(1, 2), title="Strategy Legend")
        # add allocation plots for each strategy
        stratPlots = []
        numStocks = length(simulator.strategies[1].pdb.data)-7
        stockColors = distinguishable_colors(numStocks, lchoices=range(30, 100))
        stockNames = string.(names(simulator.strategies[1].pdb.data)[8:(numStocks+8-1)])
        initialData = [zeros(2) for i in 1:numStocks]
        stockLegend = plot(initialDate, initialData, labels=stockNames, grid=false, showaxis=false, xlims=(1, 2), title="Holdings Legend", color_palette=stockColors)
        for currs in simulator.strategies
            s = plot(initialDate, initialData, title=currs.name*" Holdings Over Time", xlabel="Date", ylabel="Number of Shares", xlims=xlim, legend=false, color_palette=stockColors)
            push!(stratPlots, s)
        end
        # create master plot
        l2 = @layout [a{.3h}; b{.7h}]
        legends = plot(stratLegend, stockLegend, layout=l2)
        l = @layout [grid(length(simulator.strategies), 1) c{.17w} grid(2, 1)]
        plt = plot(stratPlots..., legends, pltRet, pltRR, layout=l, size=[1200, 800], linewidth=3)
    end
    currData = Dict(s.name=>Float64[] for s in simulator.strategies)
    for date in all_dates
        for strategy in simulator.strategies
            currData[strategy.name] = update(simulator, strategy, date)
        end
        if live_plot
            # add data to plot
            rets = [currData[s.name][2] for s in simulator.strategies]
            rrs = [currData[s.name][5] for s in simulator.strategies]
            push!(pltRet, Dates.value(date), rets)
            push!(pltRR, Dates.value(date), rrs)
            #push current allocations to plot
            ctr=1
            for strategy in simulator.strategies
                currHoldings = getPortfolioState(strategy.pdb, date)[8:length(strategy.pdb.data)]
                currHoldings = convert(Array, currHoldings)[1, :]
                push!(stratPlots[ctr], Dates.value(date), currHoldings)
                ctr+=1
            end
            display(plt)
        end
    end
    #write out finalized pdbs
    for strategy in simulator.strategies
        CSV.write(strategy.name*".csv", strategy.pdb.data)
    end
    return simulator
end
