
<!-- README.md is generated from dev/README.Rmd. Please edit that file -->

# {talib}: A Technical Analysis and Candlestick Pattern Library in R <img src="man/figures/logo.png" align="right" height="170" alt="" />

<!-- badges: start -->

[![R-CMD-check](https://github.com/serkor1/ta-lib-R/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/serkor1/ta-lib-R/actions/workflows/R-CMD-check.yaml)
[![Remote
Install](https://github.com/serkor1/ta-lib-R/actions/workflows/remote-install.yaml/badge.svg)](https://github.com/serkor1/ta-lib-R/actions/workflows/remote-install.yaml)
[![Codecov test
coverage](https://codecov.io/gh/serkor1/ta-lib-R/graph/badge.svg)](https://app.codecov.io/gh/serkor1/ta-lib-R)
[![CRAN
status](https://www.r-pkg.org/badges/version/talib)](https://CRAN.R-project.org/package=talib)
[![CRAN RStudio mirror
downloads](https://cranlogs.r-pkg.org/badges/last-month/talib?color=blue)](https://r-pkg.org/pkg/talib)
<!-- badges: end -->

[{talib}](https://serkor1.github.io/ta-lib-R/) is an R package for
technical analysis, candlestick pattern recognition, and interactive
financial charting—built on the
[TA-Lib](https://github.com/TA-Lib/ta-lib) C library. It provides 67
technical indicators, 61 candlestick patterns, and a composable charting
system powered by [{plotly}](https://github.com/plotly/plotly.R) and
[{ggplot2}](https://ggplot2.tidyverse.org/). All indicator computations
are implemented in C via `.Call()` for minimal overhead.

Alongside [{TTR}](https://github.com/joshuaulrich/TTR),
[{talib}](https://serkor1.github.io/ta-lib-R/) adds candlestick pattern
recognition and interactive charts to the R technical analysis
ecosystem.

``` r
{
    talib::chart(talib::BTC)
    talib::indicator(talib::bollinger_bands)
    talib::indicator(talib::engulfing, data = talib::BTC)
    talib::indicator(talib::RSI)
    talib::indicator(talib::trading_volume)
}
```

<img src="man/figures/README-hero-1.png" alt="" style="display: block; margin: auto;" />

## Indicators

Every indicator follows the same interface: pass an OHLCV `data.frame`
or `matrix` and get the same type back. The return type always matches
the input.

``` r
tail(
    talib::bollinger_bands(talib::BTC)
)
#>                     UpperBand MiddleBand LowerBand
#> 2024-12-26 01:00:00 104478.35   98217.88  91957.42
#> 2024-12-27 01:00:00 100877.73   97020.16  93162.59
#> 2024-12-28 01:00:00  99886.22   96516.01  93145.81
#> 2024-12-29 01:00:00  99871.12   96134.41  92397.71
#> 2024-12-30 01:00:00  99713.92   95620.42  91526.92
#> 2024-12-31 01:00:00  99373.89   95236.42  91098.95
```

## Candlestick Patterns

{talib} recognizes 61 candlestick patterns—from single-candle formations
like Doji and Hammer to multi-candle patterns like Morning Star and
Three White Soldiers. Each pattern returns a normalized score: `1`
(bullish), `-1` (bearish), or `0` (no pattern).

``` r
tail(
    talib::engulfing(talib::BTC)
)
#>                     CDLENGULFING
#> 2024-12-26 01:00:00           -1
#> 2024-12-27 01:00:00            0
#> 2024-12-28 01:00:00            0
#> 2024-12-29 01:00:00           -1
#> 2024-12-30 01:00:00            0
#> 2024-12-31 01:00:00            0
```

## Charts

Charts are built in two steps: `chart()` creates the price chart, then
`indicator()` layers on technical indicators. Overlap indicators (moving
averages, Bollinger Bands) draw on the price panel; oscillators (RSI,
MACD) get their own sub-panels.

``` r
{
    talib::chart(talib::BTC)
    talib::indicator(talib::SMA, n = 7)
    talib::indicator(talib::SMA, n = 14)
    talib::indicator(talib::MACD)
}
```

<img src="man/figures/README-charting-1.png" alt="" style="display: block; margin: auto;" />

Multiple indicators can share a sub-panel by passing them as calls:

``` r
{
    talib::chart(talib::BTC)
    talib::indicator(talib::BBANDS)
    talib::indicator(
        talib::RSI(n = 10),
        talib::RSI(n = 14),
        talib::RSI(n = 21)
    )
}
```

<img src="man/figures/README-combined-1.png" alt="" style="display: block; margin: auto;" />

The charting system ships with 5 built-in themes inspired by
[chartthemes.com](https://chartthemes.com/): `default`,
`hawks_and_doves`, `payout`, `tp_slapped`, and `trust_the_process`.
Switch themes with `set_theme()`. Both
[{plotly}](https://github.com/plotly/plotly.R) (interactive, default)
and [{ggplot2}](https://ggplot2.tidyverse.org/) (static) backends are
supported.

## Column selection

Indicators use the columns they need automatically. When your data has
non-standard column names, remap them with formula syntax:

``` r
talib::RSI(x, cols = ~price)
talib::stochastic(x, cols = ~ hi + lo + last)
```

## Naming

Functions use descriptive snake_case names, but every function is
aliased to its TA-Lib shorthand for compatibility with the broader
ecosystem:

<div align="center">

| Category              | TA-Lib (C)           | {talib}                     |
|:----------------------|:---------------------|:----------------------------|
| Overlap Studies       | `TA_BBANDS()`        | `bollinger_bands()`         |
| Momentum Indicators   | `TA_CCI()`           | `commodity_channel_index()` |
| Volume Indicators     | `TA_OBV()`           | `on_balance_volume()`       |
| Volatility Indicators | `TA_ATR()`           | `average_true_range()`      |
| Price Transform       | `TA_AVGPRICE()`      | `average_price()`           |
| Cycle Indicators      | `TA_HT_SINE()`       | `ht_sine_wave()`            |
| Pattern Recognition   | `TA_CDLHANGINGMAN()` | `hanging_man()`             |

</div>

``` r
all.equal(
    target = talib::bollinger_bands(talib::BTC),
    current = talib::BBANDS(talib::BTC)
)
#> [1] TRUE
```

## Installation[^1]

``` r
pak::pak("serkor1/ta-lib-R")
```

Or from source:

``` shell
git clone --recursive https://github.com/serkor1/ta-lib-R.git
cd ta-lib-R
make build
```

## Code of Conduct

Please note that [{talib}](https://serkor1.github.io/ta-lib-R/) is
released with a [Contributor Code of
Conduct](https://contributor-covenant.org/version/2/1/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.

[^1]: [TA-Lib](https://github.com/TA-Lib/ta-lib) is vendored via
    `CMake`, so a pre-installed TA-Lib is not required. Some systems
    (Windows in particular) may require `CMake` to be explicitly
    installed.
