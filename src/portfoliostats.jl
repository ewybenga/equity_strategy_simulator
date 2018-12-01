using Dates
include("./Portfolios.jl")
include("./PortfolioDB.jl")
include("./MarketDB.jl")

export evaluateValue

"""
  evaluateValue(portfolio, date, data)

Evaluates the value of a portfolio on a given date using the MarketDB object as the datasource.
"""
function evaluateValue(portfolio::Portfolio, date::Date, data::MarketDB)
  # initialize value as the capital in the portfolio
  val = portfolio.capital
  # iterate through portfolio and add value of each stock on that day
  for stock in keys(portfolio.holdings)
    currPrice = queryMarketDB(data, date, stock, :prc)
    # if not traded on that day find most recent traded at price
    if ismissing(currPrice)
      # find most recent trade date - assumes it has traded within the last 15 days
      recentPrices = queryMarketDB(data, date-Day(15), date, stock, :prc)
      currPrice = pop!(recentPrices)
    end
    val += currPrice[1].value * p.holdings[stock]
  end
  return val
end

"""
  computeCumulativeReturn(portfolio, date, data)

Compute the cumulative return of the portfolio since the start date
"""
function computeCumulativeReturn(portfolio::Portfolio, date::Date, data::PortfolioDB)
  # find initial value
  p_initial = 10
  # find current value
  p_current = 20
  #compute cumulative return
  return (p_current/p_initial) - 1.
end

"""
  computeAnnualizedReturn(portfolio, date, data)

Compute the annualized return of the portfolio since the start date using formula Ra = ( (1 + Rc) ^ (1/n) ) – 1
"""
function computeAnnualizedReturn(portfolio::Portfolio, date::Date, data::PortfolioDB)
  # get number of years the portfolio has existed
  numYears = 10
  # compute annualized return
  return ((1+computeCumulativeReturn(portfolio, date, data)^(1/numYears))-1)
end

"""
  computeVolatility(portfolio, date, data)

Compute the volatility of the portfolio since the start date
"""
function computeVolatility(portfolio::Portfolio, date::Date, data::PortfolioDB)
  return .1
end

"""
  computeSharpeRatio(portfolio, date, riskfreerate, data)

Compute the sharpe ratio, or risk reward ratio, using the formula sharperatio = (portfolioreturn-riskfreerate)/(stdev of portfolios excess return)
"""
function computeSharpeRatio(portfolio::Portfolio, date::Date, riskfreerate::Float64, data::PortfolioDB)
  return 10
end
