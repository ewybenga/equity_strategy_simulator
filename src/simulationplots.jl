using Plots
include("Strategies.jl")

"""
	PlotColumnForStrats(strats, col)
"""
function PlotColumnForStrats(strats::Array{Strategy, 1}, col)
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
    display(plot(x, ys, title=t, xlabel=xlab, ylabel=ylab, label=linenames))
    
end