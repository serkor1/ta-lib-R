
<!-- README.md is generated from README.Rmd. Please edit that file -->

# {talib}: R bindings for [TA-Lib](https://github.com/TA-Lib/ta-lib) <img src="man/figures/logo.png" align="right" height="170" alt="" />

<!-- badges: start -->
<!-- badges: end -->

{talib} provides R bindings for
[TA-Lib](https://github.com/TA-Lib/ta-lib), a C-library for Technical
Analysis indicators and Candlestick patterns.

{talib} also provides interactive financial charts based on {plotly}.

## Installation

You can install the development version of talib from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("serkor1/curly-giggle")
```

## Example

### Indicators

This is a basic example which shows you how to solve a common problem:

``` r
library(talib)

## calculate bollinger
## bands
x <- talib::BTC

## calculate bollinger
## bands
tail(
  talib::bollinger_bands(
    x
  )
)
```

    #>         upper   middle    lower
    #> 361 106812.14 99260.81 91709.48
    #> 362 104471.11 98218.27 91965.44
    #> 363 100874.66 97021.36 93168.05
    #> 364  99891.29 96519.09 93146.89
    #> 365  99875.94 96136.93 92397.91
    #> 366  99720.50 95622.57 91524.65

### Charting

``` r
library(talib)

## calculate bollinger
## bands
x <- talib::BTC

{
  ## calculate bollinger
  ## bands
  talib::chart(
    x = x
  )

  ## add bollinger bands
  ## to the chart
  talib::indicator(
    FUN = talib::SMA(),
    cols = ~close + open
  )

  ## add bollinger bands
  ## to the chart
  talib::indicator(
    FUN = talib::stochastic()
  )
}
```

<img src="man/figures/README-charting-1.png" style="display: block; margin: auto;" />
