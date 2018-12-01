using Test
using Dates
include("../src/Tickers.jl")
include("../src/MarketDB.jl")
include("../src/Portfolios.jl")


## MARKET DB TESTS
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
@test_throws ErrorException Ticker(m, "Q", "ABC")
tickerTest = Ticker(m, "Q", "MSFT")
@test tickerTest.exchange=="Q"
@test tickerTest.symbol=="MSFT"
@test tickerTest.start_date==Date(2008, 6, 30)
@test tickerTest.end_date==Date(2018, 6, 29)


## PORTFOLIO TESTS
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
