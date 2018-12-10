# Equity Strategy Simulator

## Obtaining Data
Daily data from CRSP (the Center for Research in Security Prices) from WRDS (Wharton Research Data Services) is used, although other data sources could be used with slight modifications in the src/MarketDB.jl file under processData. It would still need to be a csv with column headers date (the price of the security on that date), ticker (the ticker symbol), primexch (the exchange the security is traded on), divamt (the amount of the dividend issued by that security on the date), and prc (the price of the security on the date).    
    
To obtain the data from CRSP if you have access through MIT or another subscribing institution, navigate to https://libraries/.mit.edu/get/wrds and log in. Under "Your Subscriptions" click "CRSP". Next select "Stock / Security Files" and then "Daily Stock File". Choose the date range you'd like to use, the tickers to obtain data for, and the query variables "Ticker", "Price", "Primary Exchange", and "Dividend Cash Amount". This filename will be the input to the MarketDB object.   
   
To add the S&P 500 as a baseline to compare against go to CRSP -> "Index / S&P 500 Indexes" -> "CRSP Index File on the S&P 500". Be sure to change to Daily data and use "Market Value of Securities Used" as price. This will be a very high value so either divide it by a fixed amount in the csv or give the portfolio buying it a high amount of capital.

## Usage
1. Import the project
```
include("Simulator.jl")
```
2. Load the market data (prices and dividend amounts of each ticker over the date range available)
```
m = MarketDB(path_to_data)
```
3. Create all strategies to be tested. They are initialized by the line:
```
strat = Strategy(strategy_name, trade_function, initial_portfolio, market_data)
```
> The *name* is any string, for example "My Test Strategy". This is mainly used for labels for plots.      
> The *trade_function* is a function that contains the logic for how the strategy should behave/trade on a given day. It can call the functions buy and sell on the Portfolio for the strategy. It must accept (but doesn't have to use all of) the following arguments: (marketData::MarketDB, date::Date, portfolioData::PortfolioDB, portfolio::Portfolio, transfee::Float64, otherData::Dict).         
>> marketData: A MarketDB object with stock price data. It should not be queried for data beyond the current date of the simulation.    
>> date: The current date of the simulation       
>> portfolioData: A DataFrame containing the portfolio state and associated statistics for each past day of the simulation. This data may be queried without restrictions to calculate signals for the strategy.     
>> portfolio: A Portfolio object, which contains capital (a Float64 of how much capital is available to purchase stocks) and holdings (a Dict of Ticker->number_of_shares).      
>> transfee: The amount of the transaction fee, this will be passed in to a buy or sell call and be deducted from the portfolio capital if a transaction is completed.     
>> otherData: A Dict that can be used to hold any information about signals (ie weights, moving averages, etc). It is stored in the Strategy object and can be passed forward through days in the simulation.  
> 
> The *inital_portfolio* is the beginning state of the Portfolio. It is initialized as Portfolio(Dict, Float64) where the Dict is of Ticker=>number of shares and the FLoat64 is the initial amount of capital. A Ticker object is initialized with Ticker(data::MarketDB, exchange::String, symbol::String). To initialize a portfolio with only liquid capital, use Portfolio(Dict(), amt_initial_capital).      
> The *market_data* is the object created in step 2, m.   
     
To see examples of trade functions, see Strategies.jl.     

4. Create the simulator object. 
```
sim = Simulator(market_data, start_date, end_date, strategies_array, transaction_fee)
```
Use m from step 2 as the market_data, Date objects for the start and end date, and an array of Strategy objects from step 3 for strategies_array. Transaction_fee is a Float64, we used 5.0.   
   
5. Run the simulation. If you wish to display the live dashboard of plots, first set the backend using 
```
# running from command line
gr(show=:true)
# running from a notebook
gr(show=:ijulia)
```
Now call the run function. 
```
# show live dashboard of plots
runSim(sim, true)
# don't show live dashboard of plots
runSim(sim)
```
This will output an updated Simulator object with the Strategy objects in their final state. It also saves the PortfolioDBs as csvs containing the Portfolio state and statistics for each day in the simulation as strategy_name".csv". The updated Strategy objects can be used to create individual plots using 
```
# plot the value over the simulation
PlotColumnForStrats(sim.strategies, :value)
# any column can be substituted for :value
# this will save the figure to column_name" Over Time.png" unless the argument "save=false" is included.

# plot the holdings for the first strategy over the simulation
strategy_to_plot = sim.strategies[1]
PlotHoldingForStrategy(strategy_to_plot, save=false)
# if save is not specified to be false it will save the plot as strategy_name".png"
```

## Software Design
Please see JuliaProject.pdf for an overview of the code design.


### License
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
