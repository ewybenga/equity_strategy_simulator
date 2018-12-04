using Plots
include("Strategies.jl")

"""
	PlotColumnForStrats(strats, col)

Purpose: Generates a plot showing the values for the given column for all strategies in an array of strats
"""
function PlotColumnForStrats(strats::Array{Strategy, 1}, col::Symbol, s::Bool=true)
    # get dates
    x = strats[1].pdb.data.date
    # get y values
    ys = [s.pdb.data[col] for s in strats]
    # formatting vars
    linenames = [s.name for s in strats]
    linenames = reshape(linenames, (1, size(linenames)[1]))
    xlab = "Date"
    ylab = titlecase(string(col))
    t = ylab*" Over Time"
    pl = plot(x, ys, title=t, xlabel=xlab, ylabel=ylab, label=linenames)
    if s
        savefig(pl, "$t.png")
    end
    return pl
end

"""
    PlotHoldingForStrategy(strat)

Purpose: Generates a plot showing the number of holdings over time for a given strategy
"""
function PlotHoldingForStrategy(strat::Strategy, save::Bool=true)
    # get dates
    x = strat.pdb.data.date
    # get y values
    ys = []
    linenames = []
    for stock in names(strat.pdb.data[8:length(strat.pdb.data)])
        if sum(strat.pdb.data[stock]) > 0
            push!(ys, strat.pdb.data[stock])
            push!(linenames, stock)
        end
    end
    # formatting vars
    linenames = reshape(linenames, (1, size(linenames)[1]))
    xlab = "Date"
    ylab = "Holdings"
    name = strat.name
    t = "$name Holdings Over Time"
    pl = plot(x, ys, title=t, xlabel=xlab, ylabel=ylab, label=linenames)
    if save
        savefig(pl, "$t.png")
    end
    return pl
end
