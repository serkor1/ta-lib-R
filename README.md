
<!-- README.md is generated from README.Rmd. Please edit that file -->

# {talib}: A Technical Analysis and Candlestick Pattern Library in R <img src="man/figures/logo.png" align="right" height="170" alt="" />

<!-- badges: start -->

[![R-CMD-check](https://github.com/serkor1/ta-lib-R/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/serkor1/ta-lib-R/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/serkor1/ta-lib-R/graph/badge.svg)](https://app.codecov.io/gh/serkor1/ta-lib-R)
[![CRAN
status](https://www.r-pkg.org/badges/version/talib)](https://CRAN.R-project.org/package=talib)
[![CRAN RStudio mirror
downloads](https://cranlogs.r-pkg.org/badges/last-month/talib?color=blue)](https://r-pkg.org/pkg/talib)
<!-- badges: end -->

[{talib}](https://serkor1.github.io/ta-lib-R/) is an `R`-package for
Technical Analysis and algorithmic Candlestick pattern recognition built
on the `C` library [TA-Lib](https://github.com/TA-Lib/ta-lib).
[{talib}](https://serkor1.github.io/ta-lib-R/) extends
[{TTR}](https://github.com/joshuaulrich/TTR) by adding Candlestick
pattern recognition to the pool of available indicators, and interactive
charts via [{plotly}](https://github.com/plotly/plotly.R).

[TA-Lib](https://github.com/TA-Lib/ta-lib) supports 200+ indicators for
Technical Analysis and Candlestick Patterns, all of which are available
in [{talib}](https://serkor1.github.io/ta-lib-R/).

## Types of Indicators and Interface

In the core C library functions are named as `TA_INDICATOR()` and
`TA_CDLPATTERN()` for indicators and patterns respectively. In the
`Python`-wrapper the functions are named `INDICATOR()` and
`CDLPATTERN()`—but this `R` package follows the [tidyverse
styleguide](https://style.tidyverse.org/) and therefore the naming is
inconsistent with the core library and the Python wrapper. See below for
an example of the mapping:

<div align="center">

| Function Group        | TA-Lib (core)        | {talib}                     |
|:----------------------|:---------------------|:----------------------------|
| Overlap Studies       | `TA_BBANDS()`        | `bollinger_bands()`         |
| Momentum Indicators   | `TA_CCI()`           | `commodity_channel_index()` |
| Volume Indicators     | `TA_OBV()`           | `on_balance_volume()`       |
| Volatility Indicators | `TA_ATR()`           | `average_true_range()`      |
| Price Transform       | `TA_AVGPRICE()`      | `average_price()`           |
| Cycle Indicators      | `TA_HT_SINE()`       | `ht_sine_wave()`            |
| Pattern Recognition   | `TA_CDLHANGINGMAN()` | `hanging_man()`             |

</div>

However, each function in [{talib}](https://serkor1.github.io/ta-lib-R/)
is aliased so its consistent with the remaining ecosystem. See below:

``` r
all.equal(
    target = talib::bollinger_bands(talib::BTC),
    current = talib::BBANDS(talib::BTC)
)
#> [1] TRUE
```

The aliases are exported but are not a part of the documentation, but
they behave exactly the same as the main functions as demonstrated
above.

## Basic Usage

Below are an example on how to use
[{talib}](https://serkor1.github.io/ta-lib-R/) to calculate an indicator
and charting it.

### Indicators

``` r
## calculate bollinger
## bands
tail(
    talib::bollinger_bands(
        talib::BTC
    )
)
#>         upper   middle    lower
#> 361 106812.14 99260.81 91709.48
#> 362 104471.11 98218.27 91965.44
#> 363 100874.66 97021.36 93168.05
#> 364  99891.29 96519.09 93146.89
#> 365  99875.94 96136.93 92397.91
#> 366  99720.50 95622.57 91524.65
```

### Charting

``` r

{
    ## main chart
    talib::chart(
        talib::BTC,
        ## optional idx-argument
        ## for adding dates to chart
        idx = rownames(talib::BTC)
    )

    ## add bollinger bands
    ## to chart
    talib::indicator(
        talib::bollinger_bands
    )
}
```

<img src="man/figures/README-charting-1.png" style="display: block; margin: auto;" />

## Installation

[TA-Lib](https://github.com/TA-Lib/ta-lib) is vendored in
[{talib}](https://serkor1.github.io/ta-lib-R/) via `CMake`, so it is not
necessary to have [TA-Lib](https://github.com/TA-Lib/ta-lib)
pre-installed.[^1]

### Stable version

``` r
pak::pak("talib")
```

### Development version

The development version can be installed by recursive cloning the
repository and using the available build tools as follows:

``` shell
git clone --recursive https://github.com/serkor1/ta-lib-R.git
cd ta-lib-R
make build
```

Use `make` to see package-level build-tools.

## Code of Conduct

Please note that [{talib}](https://serkor1.github.io/ta-lib-R/) is
released with a [Contributor Code of
Conduct](https://contributor-covenant.org/version/2/1/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.

[^1]: Some systems (Windows in particular) may require you to explicitly
    install and link `CMake` for
    [{talib}](https://serkor1.github.io/ta-lib-R/) to build properly.
