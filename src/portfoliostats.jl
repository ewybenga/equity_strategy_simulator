using Dates
using Statistics
include("./Portfolios.jl")
include("./PortfolioDB.jl")
include("./MarketDB.jl")

export evaluateValue

"""
  getMostRecentPrice(mdb, date, stock, ndays)

Gets the price of the stock on the most recently traded day to "date". Search within last ndays (defaults to 15 days or num days since start of MarketDB). Assumes stock is traded on first day of MarketDB (this is a somewhat strict assumption)
"""
function getMostRecentPrice(mdb::MarketDB, date::Date, stock::Ticker, ndays::Int64=15)
  currPrice = queryMarketDB(mdb, date, stock, :prc)
  # if not traded on that day find most recent traded at price
  if ismissing(currPrice)
    # check that not within first 15 days or modify bounds
    minDate = minimum(unique(mdb.data[:date]))
    daysFromMin = date - minDate
    if daysFromMin < Day(ndays)
      ndays = daysFromMin
    end
    # find most recent trade date - assumes it has traded within the last 15 days
    recentPrices = queryMarketDB(mdb, date-Day(ndays), date, stock, :prc)
    currPrice = pop!(recentPrices).value
  else
    currPrice = currPrice[1].value
  end
  return currPrice
end

"""
  evaluateValue(portfolio, date, data)

Evaluates the value of a portfolio on a given date using the MarketDB object as the datasource.
"""
function evaluateValue(portfolio::Portfolio, date::Date, data::MarketDB)
  # initialize value as the capital in the portfolio
  val = portfolio.capital
  # iterate through portfolio and add value of each stock on that day
  for stock in keys(portfolio.holdings)
    currPrice = getMostRecentPrice(data, date, stock)
    val += currPrice * portfolio.holdings[stock]
  end
  return round(val, digits=2)
end

"""
  computeCumulativeReturn(portfolio, date, data)

Compute the cumulative return of the portfolio since the start date. Formula is (p_current/p_initial)-1
"""
function computeCumulativeReturn(portfolio::Portfolio, date::Date, pdb::PortfolioDB, mdb::MarketDB)
  # handle first day
  if size(pdb.data)[1] == 0
    return 0.
  end
  # find initial value
  p_initial = pdb.data[1,:value]
  # find current value
  p_current = evaluateValue(portfolio, date, mdb)
  #compute cumulative return
  return (p_current/p_initial) - 1.
end

"""
  computeAnnualizedReturn(portfolio, date, data)

Compute the annualized return of the portfolio since the start date using formula Ra = ( (1 + Rc) ^ (1/n) ) – 1
"""
function computeAnnualizedReturn(portfolio::Portfolio, date::Date, pdb::PortfolioDB, mdb::MarketDB)
  # handle first day
  if size(pdb.data)[1] == 0
    return 0.
  end
  # get number of years the portfolio has existed
  numYears = (365.)/(date-pdb.data[:date][1]).value
  # compute annualized return
  return (1+computeCumulativeReturn(portfolio, date, pdb, mdb))^(1/numYears)-1
end

"""
  computeVolatility(curr_annual_return, date, data)

Compute the volatility of the portfolio since the start date
"""
function computeVolatility(curr_annual_return::Float64, data::PortfolioDB)
  rets = data.data[:return_annual]
  push!(rets, curr_annual_return)
  return std(rets)
end

"""
  computeRiskReward(portfolio, date, riskfreerate, data)

Compute the sharpe ratio, or risk reward ratio, using the formula sharperatio = (portfolioreturn-riskfreerate)/(stdev of portfolios excess return)

Default: assume risk free rate is 0
"""
function computeRiskReward(curr_annual_return::Float64, curr_volatility::Float64, risk_free_rate::Float64=0.0)
  return (curr_annual_return - risk_free_rate)/curr_volatility
end
