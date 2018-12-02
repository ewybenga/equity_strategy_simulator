using Test
using Dates
include("../src/Tickers.jl")
include("../src/MarketDB.jl")
include("../src/Portfolios.jl")
include("../src/PortfolioDB.jl")
include("../src/portfoliostats.jl")


## MARKET DB TESTS
println("Beginning MarketDB Tests...")
m = MarketDB("../data/data.csv")
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
println("Beginning Tickers Tests...")
@test_throws ErrorException Ticker(m, "Q", "ABC")
tickerTest = Ticker(m, "Q", "MSFT")
@test tickerTest.exchange=="Q"
@test tickerTest.symbol=="MSFT"
@test tickerTest.start_date==Date(2008, 6, 30)
@test tickerTest.end_date==Date(2018, 6, 29)


## PORTFOLIO TESTS
println("Beginning Portfolio Tests...")
tickerTest2 = Ticker(m, "Q", "GOOG")
# test creation of portfolio
portfolioTest = Portfolio(Dict(tickerTest=>1, tickerTest2=>4), 1000)
@test portfolioTest.holdings == Dict(tickerTest=>1, tickerTest2=>4)
@test portfolioTest.capital == 1000
tickerTest3 = Ticker(m, "Q", "TSLA")
# test buying a stock not already in the portfolio
@test buy(portfolioTest, tickerTest3, 2., Date(2016, 9, 1), 5., m) == (2.0, 200.77)
@test portfolioTest.capital == 1000-200.77*2-5
@test portfolioTest.holdings == Dict(tickerTest=>1, tickerTest2=>4, tickerTest3=>2)
# try to buy a stock on a day the market was closed
@test buy(portfolioTest, tickerTest3, 2., Date(2016, 1, 1), 5., m) == (0, :None)
@test portfolioTest.capital == 1000-200.77*2-5
@test portfolioTest.holdings == Dict(tickerTest=>1, tickerTest2=>4, tickerTest3=>2)
# try to buy 3 TSLA stocks (only enough capital for 2)
@test buy(portfolioTest, tickerTest3, 3., Date(2016, 9, 1), 5., m) == (2.0, 200.77)
@test portfolioTest.capital == round(1000-200.77*4-10, digits=2)
@test portfolioTest.holdings == Dict(tickerTest=>1, tickerTest2=>4, tickerTest3=>4)
# try to buy expensive google with not enough money, portfolio shouldn't change
expensiveGoogle = Ticker(m, "Q", "GOOGL")
@test buy(portfolioTest, expensiveGoogle, 1., Date(2016, 9, 2), 5., m) == (0, 796.87)
@test portfolioTest.capital == round(1000-200.77*4-10, digits=2)
@test portfolioTest.holdings == Dict(tickerTest=>1, tickerTest2=>4, tickerTest3=>4)
# buy another microsoft
@test buy(portfolioTest, tickerTest, 1., Date(2016, 9, 2), 5., m) == (1, 57.67)
@test portfolioTest.capital == round(1000-200.77*4-57.67-15, digits=2)
@test portfolioTest.holdings == Dict(tickerTest=>2, tickerTest2=>4, tickerTest3=>4)
# sell microsoft on a weekend
@test sell(portfolioTest, tickerTest, 1., Date(2016, 9, 3), 5., m) == (0, :None)
@test portfolioTest.capital == round(1000-200.77*4-57.67-15, digits=2)
@test portfolioTest.holdings == Dict(tickerTest=>2, tickerTest2=>4, tickerTest3=>4)
# sell exactly all of the GOOGs
@test sell(portfolioTest, tickerTest2, 4., Date(2016, 9, 6), 5., m) == (4., 780.08002)
@test portfolioTest.capital == round(1000-200.77*4-57.67-20+780.08*4, digits=2)
@test portfolioTest.holdings == Dict(tickerTest=>2, tickerTest3=>4)
# try to sell more TSLAs than we have
@test sell(portfolioTest, tickerTest3, 5., Date(2016, 9, 6), 5., m) == (4., 202.83)
@test portfolioTest.capital ≈ round(1000-200.77*4-57.67-25+780.08*4+202.83*4, digits=2)
@test portfolioTest.holdings == Dict(tickerTest=>2)
# sell one MSFT
@test sell(portfolioTest, tickerTest, 1., Date(2016, 9, 6), 5., m) == (1., 57.61)
@test portfolioTest.capital ≈ round(1000-200.77*4-57.67-30+780.08*4+202.83*4+57.61, digits=2)
@test portfolioTest.holdings == Dict(tickerTest=>1)
# try to sell a stock we don't have in the portfolio
@test sell(portfolioTest, tickerTest2, 1., Date(2016, 9, 6), 5., m) == (0., :None)
@test portfolioTest.capital ≈ round(1000-200.77*4-57.67-30+780.08*4+202.83*4+57.61, digits=2)
@test portfolioTest.holdings == Dict(tickerTest=>1)
# check that dividends will be addded for days with dividend returns and not for days without dividend returns
divTest = Portfolio(Dict(tickerTest=>4, tickerTest2=>4), 1000)
addDividend(Date(2008,8,19),m,divTest)
@test divTest.capital == 1000.44
addDividend(Date(2008,6,30),m,divTest)
@test divTest.capital == 1000.44

#PORTFOLIODB TESTS
println("Beginning PortfolioDB Tests...")
pdb = PortfolioDB(m)
cols = string.(names(pdb.data))
uniqueTickers = unique(m.data.ticker)
# check correct columns initialized
for t in uniqueTickers
    @test t in cols
end
for s in ["date", "value", "return_cumulative", "return_annual", "volatility", "riskreward", "value"]
    @test s in cols
end
# test writing to pdb
d = Date(2016, 9, 6)
writePortfolio(pdb, d, portfolioTest, .13, .56, evaluateValue(portfolioTest, d, m), .05, .13)
@test size(pdb.data)[1]==1
@test pdb.data[:date][1]==d
@test pdb.data[:capital][1]==portfolioTest.capital
@test pdb.data[:MSFT][1]==1.
@test pdb.data[:value][1]==4156.11
# buy a stock and write the next day
buy(portfolioTest, tickerTest3, 3., Date(2016, 9, 7), 5., m)
writePortfolio(pdb, d+Day(1), portfolioTest, .13, .56, evaluateValue(portfolioTest, d, m), .05, .13)
@test size(pdb.data)[1]==2
@test pdb.data[:MSFT][2]==1.
@test pdb.data[:TSLA][2]==3.
@test pdb.data[:capital][2]==portfolioTest.capital
# test query on a certain day
@test ismissing(getPortfolioState(pdb, d-Day(1)))
@test getPortfolioState(pdb, d)[:capital][1]==4098.5

println("TESTING COMPLETE")
