
<!-- README.md is generated from dev/README.Rmd. Please edit that file -->

# {talib}: Fast TA-Lib indicators and candlestick patterns for R <img src="man/figures/logo.png" align="right" height="170" alt="" />

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

[{talib}](https://serkor1.github.io/ta-lib-R/) provides fast R bindings
to the TA-Lib C library for OHLCV data: technical indicators,
candlestick pattern recognition, rolling-window utilities, and
composable financial charts. It is designed for researchers, analysts,
and quant developers who need technical-analysis features in R without
building a heavy dependency stack. Core computations are executed in C
through `.Call()`, while charting support is available through optional
`plotly` and `ggplot2` integrations.

## Why {talib}?

<div align="center">

| Need                 | {talib}                                                                                 |
|----------------------|-----------------------------------------------------------------------------------------|
| Technical indicators | TA-Lib-backed moving averages, momentum, volatility, volume, cycle, and overlap studies |
| Candlestick patterns | Built-in Japanese candlestick pattern recognition                                       |
| OHLCV workflows      | Works directly with open, high, low, close, and volume columns                          |
| Performance          | Computation delegated to C routines through `.Call()`                                   |
| Dependencies         | Minimal required R dependencies; plotting packages are optional                         |
| Charts               | Composable financial charts with optional `plotly` and `ggplot2` support                |

</div>

## Installation

Install the release version from CRAN:

``` r
install.packages("talib")
```

Install the development version from GitHub:

``` r
pak::pak("serkor1/ta-lib-R")
```

## Quick start

All functions are based on `S3`-classes with dispatches on
`<data.frame>`, `<matrix>` and—where applicable—`<vector>`. The rule(s)
are simple: `<class>` in, `<class>` out.

``` r
## combine candlestick patterns
## into a single <data.frame>
tail(
    candlestick_patterns <- data.frame(
        doji        = talib::doji(talib::BTC),
        engulfing   = talib::engulfing(talib::BTC),
        black_crows = talib::three_black_crows(talib::BTC)
    )
)
#>                     CDLDOJI CDLENGULFING CDL3BLACKCROWS
#> 2024-12-26 01:00:00       0           -1              0
#> 2024-12-27 01:00:00       0            0              0
#> 2024-12-28 01:00:00       0            0              0
#> 2024-12-29 01:00:00       0           -1              0
#> 2024-12-30 01:00:00       0            0              0
#> 2024-12-31 01:00:00       0            0              0
```

## Technical indicators and candlestick patterns

**Technical indicators—**

**Candlestick patterns—**

## Aggressive optimizations

Unknown flags passed to `configure` are forwarded verbatim to both the
CMake build of the vendored TA-Lib and the R wrapper compile step.
Rebuild from source with any compiler flags you like:

``` r
install.packages(
    "talib",
    type = "source",
    configure.args = "-O3 -march=native"
)
```

Or from a local clone:

## Implementation: {talib} vs TA-Lib Core

Functions use descriptive snake_case names, but every function is
aliased to its TA-Lib shorthand for compatibility with the broader
ecosystem:

<div align="center">

| Category              | TA-Lib (C)           | {talib}                     | {talib} alias     |
|:----------------------|:---------------------|:----------------------------|:------------------|
| Overlap Studies       | `TA_BBANDS()`        | `bollinger_bands()`         | `BBANDS()`        |
| Momentum Indicators   | `TA_CCI()`           | `commodity_channel_index()` | `CCI()`           |
| Volume Indicators     | `TA_OBV()`           | `on_balance_volume()`       | `OBV()`           |
| Volatility Indicators | `TA_ATR()`           | `average_true_range()`      | `ATR()`           |
| Price Transform       | `TA_AVGPRICE()`      | `average_price()`           | `AVGPRICE()`      |
| Cycle Indicators      | `TA_HT_SINE()`       | `sine_wave()`               | `HT_SINE()`       |
| Pattern Recognition   | `TA_CDLHANGINGMAN()` | `hanging_man()`             | `CDLHANGINGMAN()` |

</div>

``` r
## snake_case and TA-Lib aliases
## are identical
all.equal(
    target  = talib::bollinger_bands(BTC),
    current = talib::BBANDS(BTC)
)
#> [1] TRUE
```

## Contributing and cloning

[TA-Lib](https://github.com/TA-Lib/ta-lib) is vendored via
`.gitsubmodule` and all clones should be done with `--recursive` as
follows:

``` shell
git clone --recursive https://github.com/serkor1/ta-lib-R.git
cd ta-lib-R
R CMD INSTALL . --configure-args="-O3 -march=native"
```

All indicators, functions and (most) unit-tests are generated
automatically via BASH in the `codegen`-folder—except for the charting
interface. The documentation is autogenerated via `man-roxygen`
similarily. All relevant folders include a GPT-generated `README` which
should give a proper description on how to use the tools.

> Suggestions, objections and complaints are more than welcome. Feel
> free to open an issue or a PR—but it is recommended to open an issue
> before commencing any significant work.

## Code of Conduct

Please note that [{talib}](https://serkor1.github.io/ta-lib-R/) is
released with a [Contributor Code of
Conduct](https://contributor-covenant.org/version/2/1/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.
