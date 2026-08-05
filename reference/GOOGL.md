# Alphabet Inc. (GOOGL)

Daily OHLCV price data for Alphabet Inc. (GOOGL), denominated in USD,
covering 2019-01-01 to 2021-12-31. Stored as an `xts` object with a
`Date` index and quantmod-style prefixed column names - the exact shape
returned by `quantmod::getSymbols()` - and used by the unit tests for
the `xts` methods.

## Usage

``` r
GOOGL
```

## Format

An `xts` object with 756 rows and 6 columns.

- GOOGL.Open:

  Opening price for the trading day.

- GOOGL.High:

  Highest price reached during the trading day.

- GOOGL.Low:

  Lowest price reached during the trading day.

- GOOGL.Close:

  Closing price for the trading day.

- GOOGL.Volume:

  Total trading volume for the day.

- GOOGL.Adjusted:

  Adjusted closing price for the trading day.

## Source

Loaded using
[quantmod](https://cran.r-project.org/web/packages/quantmod/index.html).

## Examples

``` r
## Load the dataset
data(GOOGL, package = "talib")

## Scan for Doji patterns on GOOGL
talib::doji(GOOGL)
#>            CDLDOJI
#> 2019-01-02      NA
#> 2019-01-03      NA
#> 2019-01-04      NA
#> 2019-01-07      NA
#> 2019-01-08      NA
#> 2019-01-09      NA
#> 2019-01-10      NA
#> 2019-01-11      NA
#> 2019-01-14      NA
#> 2019-01-15      NA
#>        ...        
#> 2021-12-16       0
#> 2021-12-17       0
#> 2021-12-20       0
#> 2021-12-21       0
#> 2021-12-22       0
#> 2021-12-23       0
#> 2021-12-27       0
#> 2021-12-28       0
#> 2021-12-29     100
#> 2021-12-30       0
```
