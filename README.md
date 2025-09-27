
<!-- README.md is generated from README.Rmd. Please edit that file -->

# {talib}: R bindings for [TA-Lib](https://github.com/TA-Lib/ta-lib) <img src="man/figures/logo.png" align="right" height="170" alt="" />

<!-- badges: start -->

[![R-CMD-check](https://github.com/serkor1/ta-lib-R/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/serkor1/ta-lib-R/actions/workflows/R-CMD-check.yaml)
[![R-CMD-check](https://github.com/serkor1/ta-lib-R/actions/workflows/R-CMD-check-system.yaml/badge.svg)](https://github.com/serkor1/ta-lib-R/actions/workflows/R-CMD-check-system.yaml)
[![Codecov test
coverage](https://codecov.io/gh/serkor1/ta-lib-R/graph/badge.svg)](https://app.codecov.io/gh/serkor1/ta-lib-R)
[![CRAN
status](https://www.r-pkg.org/badges/version/talib)](https://CRAN.R-project.org/package=talib)
[![CRAN RStudio mirror
downloads](https://cranlogs.r-pkg.org/badges/last-month/talib?color=blue)](https://r-pkg.org/pkg/talib)
<!-- badges: end -->

[{talib}]() provides high-performance R bindings to the
[TA-Lib](https://github.com/TA-Lib/ta-lib) C-library for Technical
Analysis indicators, Candlestick patterns and interactive charting via
[{plotly}]().

## Installation

### Stable version

``` r
pak::pak("talib")
```

### Development version

The development version can be installed via:[^1]

``` r
pak::pak("serkor1/ta-lib-R")
```

Or it can be installed by cloning the repository:

``` sh
git clone --recursive https://github.com/serkor1/ta-lib-R.git
cd ta-lib-R
make build
```

Use `make` for all package-level build-tools.

## Basic Usage

### Indicators

This is a basic example which shows you how to solve a common problem:

``` r
## calculate bollinger
## bands
tail(
  talib::bollinger_bands(
    talib::BTC
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
  ## chart Bitcoin
  ## with candlesticks
  talib::chart(
    x = x
  )

  ## add bollinger bands
  ## to the chart
  talib::indicator(
    FUN = talib::SMA,
    cols = ~ close + open
  )

  ## add bollinger bands
  ## to the chart
  talib::indicator(
    FUN = talib::bollinger_bands
  )

  ## add RSI indicator
  ## to the chart
  talib::indicator(
    FUN = talib::relative_strength_index
  )

  ## add harami indicators
  ## to the chart
  talib::indicator(
    FUN = talib::harami
  )
}
```

<img src="man/figures/README-charting-1.png" style="display: block; margin: auto;" />

## Code of Conduct

Please note that [{talib}]() is released with a [Contributor Code of
Conduct](https://contributor-covenant.org/version/2/1/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.

[^1]: Requires that [TA-Lib]() is preinstalled.
