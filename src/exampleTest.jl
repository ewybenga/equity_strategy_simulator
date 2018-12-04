include("./Simulator.jl")
println("Loading market data...")
m = MarketDB("../data/datasp.csv")
println("Building strategies...")
strat1 = Strategy("HoldMicrosoft", Example1, Portfolio(Dict(), 10000), m)
strat4 = Strategy("buyDropSellGain", buyDropSellGain, Portfolio(Dict(), 10000), m)
println("Building simulator...")
sim = Simulator(m, Date(2013, 6, 1), Date(2015, 6, 1), [strat1, strat4], 5.)
println("Beginning simulation...")
gr(show=:true)
runSim(sim, true)
println("Simulation completed.")
