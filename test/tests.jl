using Test
using Dates
include("../src/Tickers.jl")
include("../src/MarketDB.jl")
include("../src/Portfolios.jl")
m = MarketDB("../data/data.csv")
## MARKET DB TESTS
#test size of sample db
@test size(m.data)==(38494, 5)
#test correct columns in sample db
@test :date in names(m.data)
@test :ticker in names(m.data)
@test :primexch in names(m.data)
@test :divamt in names(m.data)
@test :prc in names(m.data)
#test correct types in sample db
@test typeof(m.data[:date])==Array{Date,1}
@test typeof(m.data[:ticker])==Array{String,1}
@test typeof(m.data[:primexch])==Array{String, 1}
@test typeof(m.data[:divamt])==Array{Float64,1}
@test typeof(m.data[:prc])==Array{Union{Missing, Float64},1}


## STOCK TICKER TESTS
@test_throws ErrorException Ticker(m, "Q", "ABC")
tickerTest = Ticker(m, "Q", "MSFT")
@test tickerTest.exchange=="Q"
@test tickerTest.symbol=="MSFT"
@test tickerTest.start_date==Date(2008, 6, 30)
@test tickerTest.end_date==Date(2018, 6, 29)
