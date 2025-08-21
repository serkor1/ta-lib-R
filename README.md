
<!-- README.md is generated from README.Rmd. Please edit that file -->

# {talib}: R bindings for [TA-Lib](https://github.com/TA-Lib/ta-lib) <img src="man/figures/candlestick.png" align="right" height="150" alt="" />

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
    x[,1]
  )
)
```

    #>           upper   middle    lower
    #> [195,] 113734.0 113371.6 113009.1
    #> [196,] 113735.5 113426.4 113117.4
    #> [197,] 113738.7 113469.4 113200.0
    #> [198,] 113732.7 113506.5 113280.4
    #> [199,] 113747.5 113530.7 113314.0
    #> [200,] 113808.6 113579.7 113350.8

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
    .f = talib::SMA(),
    .var = ~close
  )

  ## add bollinger bands
  ## to the chart
  talib::indicator(
    .f = talib::RSI(),
    .var = ~close
  )
}
```

<img src="man/figures/README-charting-1.png" style="display: block; margin: auto;" />
