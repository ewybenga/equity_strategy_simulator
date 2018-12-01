using Dates
include("./Portfolios.jl")
include("./PortfolioDB.jl")
include("./MarketData.jl")

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
