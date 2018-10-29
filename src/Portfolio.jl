module Portfolio
  using Dates

  """
      Portfolio(holdings, capital)

  The Portfolio object contains a dictionary of holdings (ticker:number of shares) as well as the amount of liquid capital available

  """

  mutable struct Portfolio
      holdings::Dict{Ticker, Float64}
      capital::Float64
  end




  """
    PortfolioState(portfolio, start_date, current_date)

  The PortfolioState object contains a portfolio as well as the start_date of the period, used to compute
  information such as returns over time, and the current_date. The PortfolioState represents the portfolio's
  holdings at a given place in time.

  """

  struct PortfolioState
    currPortfolio::Portfolio
    start_date::Dates.Date
    curr_date::Dates.Date
  end


export Portfolio
export PortfolioState

end