# Equity Strategy Simulator

## Obtaining Data
Daily data from CRSP (the Center for Research in Security Prices) from WRDS (Wharton Research Data Services) is used, although other data sources could be used with slight modifications in the src/MarketDB.jl file under processData. It would still need to be a csv with column headers date (the price of the security on that date), ticker (the ticker symbol), primexch (the exchange the security is traded on), divamt (the amount of the dividend issued by that security on the date), and prc (the price of the security on the date).    
    
To obtain the data from CRSP if you have access through MIT or another subscribing institution, navigate to https://libraries/.mit.edu/get/wrds and log in. 

## Usage

## Software Design
Please see JuliaProject.pdf for an overview of the code design.


### License
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
