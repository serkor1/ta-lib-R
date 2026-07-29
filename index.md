# {talib}: Fast TA-Lib indicators and candlestick patterns for R

[{talib}](https://serkor1.github.io/ta-lib-R/) provides fast R bindings
to the [TA-Lib](https://github.com/TA-Lib/ta-lib) C library for OHLCV
data: technical indicators, candlestick pattern recognition,
rolling-window utilities, and composable financial charts. It is
designed for researchers, analysts, and quant developers who need
technical-analysis features in R without building a heavy dependency
stack. Core computations are executed in C through
[`.Call()`](https://rdrr.io/r/base/CallExternal.html), while charting
support is available through optional
[{plotly}](https://github.com/plotly/plotly.R) and
[{ggplot2}](https://ggplot2.tidyverse.org/) integrations.[^1]

The API covers 150+ [TA-Lib](https://github.com/TA-Lib/ta-lib)-backed
functions across momentum, overlap, volatility, volume, cycle,
price-transform, rolling-statistics, and candlestick-pattern families,
including 61 candlestick pattern detectors.

## Why {talib}?

| Need | {talib} |
|:---|:---|
| Technical indicators | TA-Lib-backed moving averages, momentum, volatility, volume, cycle, and overlap studies |
| Candlestick patterns | Built-in Japanese candlestick pattern recognition |
| OHLCV workflows | Works directly with open, high, low, close, and volume columns |
| Performance | Computation delegated to C routines through [`.Call()`](https://rdrr.io/r/base/CallExternal.html) |
| Dependencies | Minimal required R dependencies; plotting packages are optional |
| Charts | Composable financial charts with optional [plotly](https://plotly-r.com) and [ggplot2](https://ggplot2.tidyverse.org) support |

## Installation[^2]

Install the release version from CRAN:

``` r

install.packages("talib")
```

Install the development version from GitHub:

``` r

pak::pak("serkor1/ta-lib-R")
```

## Quick start

All functions provide S3 methods for `<data.frame>`, `<matrix>`,
and—where applicable—`<vector>` inputs. The general convention is
simple: the output uses the same container type as the input.

``` r

## calculate the
## relative strength index
relative_strength_index <- talib::RSI(
    talib::BTC
)

## display results
tail(
    relative_strength_index
)
#>                          RSI
#> 2024-12-26 01:00:00 46.48851
#> 2024-12-27 01:00:00 43.85488
#> 2024-12-28 01:00:00 45.93888
#> 2024-12-29 01:00:00 43.12301
#> 2024-12-30 01:00:00 41.47686
#> 2024-12-31 01:00:00 43.37358
```

Indicator outputs preserve input length, which keeps results aligned
with the original OHLCV rows.

``` r

## combine multiple
## indicators
features <- cbind(
    talib::relative_strength_index(talib::BTC),
    talib::bollinger_bands(talib::BTC),
    talib::engulfing(talib::BTC)
)

tail(features)
#>                          RSI UpperBand MiddleBand LowerBand CDLENGULFING
#> 2024-12-26 01:00:00 46.48851 100487.38   96698.61  92909.83         -100
#> 2024-12-27 01:00:00 43.85488 100670.65   96512.96  92355.27            0
#> 2024-12-28 01:00:00 45.93888 100632.13   96581.91  92531.69            0
#> 2024-12-29 01:00:00 43.12301  99628.77   95576.60  91524.43         -100
#> 2024-12-30 01:00:00 41.47686  96403.53   94231.31  92059.09            0
#> 2024-12-31 01:00:00 43.37358  95441.13   93774.23  92107.34            0
```

## Charting

[{talib}](https://serkor1.github.io/ta-lib-R/) comes with a composable
charting API built on two core functions:
[`indicator()`](https://serkor1.github.io/ta-lib-R/reference/indicator.md)
and
[`chart()`](https://serkor1.github.io/ta-lib-R/reference/chart.md)—both
functions are built on `model.frame` for maximum flexibility:

``` r

## subset data and
## store as 'BTC'
BTC <- talib::BTC[1:75, ]

## construct chart in a brace block
## alternatively use `|>`
{
    ## initialize main chart
    talib::chart(
        x     = BTC,
        title = "Bitcoin"
    )

    ## add Bollinger Bands to
    ## the existing chart
    talib::indicator(
        talib::BBANDS
    )

    ## add Simple Moving Averages (SMA)
    ## to the chart in a loop
    for (timePeriod in seq(5, 15, by = 3)) {
        talib::indicator(
            talib::SMA,
            timePeriod = timePeriod
        )
    }

    ## similar subchart indicators
    ## like the Relative Strength Index
    ## can be grouped to avoid repeated
    ## subpanels
    talib::indicator(
        talib::RSI(timePeriod = 10),
        talib::RSI(timePeriod = 14),
        talib::RSI(timePeriod = 21)
    )

    ## identify Doji patterns
    ## and add them to the chart
    talib::indicator(
        talib::doji
    )
}
```

![](reference/figures/README-charting-example-1.png)

## Implementation: {talib} vs upstream (TA-Lib Core)

Functions use descriptive snake_case names, but every function is
aliased to its [TA-Lib](https://github.com/TA-Lib/ta-lib) shorthand for
compatibility with the broader ecosystem:

| Category | TA-Lib (C) | {talib} | {talib} alias |
|:---|:---|:---|:---|
| Overlap Studies | `TA_BBANDS()` | [`bollinger_bands()`](https://serkor1.github.io/ta-lib-R/reference/bollinger_bands.md) | [`BBANDS()`](https://serkor1.github.io/ta-lib-R/reference/bollinger_bands.md) |
| Momentum Indicators | `TA_CCI()` | [`commodity_channel_index()`](https://serkor1.github.io/ta-lib-R/reference/commodity_channel_index.md) | [`CCI()`](https://serkor1.github.io/ta-lib-R/reference/commodity_channel_index.md) |
| Volume Indicators | `TA_OBV()` | [`on_balance_volume()`](https://serkor1.github.io/ta-lib-R/reference/on_balance_volume.md) | [`OBV()`](https://serkor1.github.io/ta-lib-R/reference/on_balance_volume.md) |
| Volatility Indicators | `TA_ATR()` | [`average_true_range()`](https://serkor1.github.io/ta-lib-R/reference/average_true_range.md) | [`ATR()`](https://serkor1.github.io/ta-lib-R/reference/average_true_range.md) |
| Price Transform | `TA_AVGPRICE()` | [`average_price()`](https://serkor1.github.io/ta-lib-R/reference/average_price.md) | [`AVGPRICE()`](https://serkor1.github.io/ta-lib-R/reference/average_price.md) |
| Cycle Indicators | `TA_HT_SINE()` | [`sine_wave()`](https://serkor1.github.io/ta-lib-R/reference/sine_wave.md) | [`HT_SINE()`](https://serkor1.github.io/ta-lib-R/reference/sine_wave.md) |
| Pattern Recognition | `TA_CDLHANGINGMAN()` | [`hanging_man()`](https://serkor1.github.io/ta-lib-R/reference/hanging_man.md) | [`CDLHANGINGMAN()`](https://serkor1.github.io/ta-lib-R/reference/hanging_man.md) |

### Interface: R vs Python

The main difference between the R and Python interfaces is how OHLCV
series are passed into each indicator function. Below is an example of
identifying `Doji` patterns in R and Python.

In Python, each series is passed independently:

``` python
import numpy as np
import talib

o = np.array([1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], dtype=float)
h = np.array([2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2], dtype=float)
l = np.array([1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], dtype=float)
c = np.array([2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1], dtype=float)

print(
    talib.CDLDOJI(o, h, l, c)
)
```

In R the series are passed as a tabular container:

``` r

ohlc <- data.frame(
    open  = c(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
    high  = c(2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2),
    low   = c(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
    close = c(2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1) 
)

talib::CDLDOJI(
    ohlc
)
```

All default series arguments are handled internally, and the `R`
interface is therefore higher-level: users pass one OHLC container
rather than manually splitting the series.

## Contributing and cloning

Contributions are welcome. For non-trivial changes, please open an issue
first to discuss the proposed design, API impact, and testing approach.

This repository vendors [TA-Lib](https://github.com/TA-Lib/ta-lib) as a
Git submodule. Clone the repository with submodules enabled:

``` sh
git clone --recurse-submodules https://github.com/serkor1/ta-lib-R.git
cd ta-lib-R
```

If you already cloned the repository without submodules, initialize them
with:

``` sh
git submodule update --init --recursive
```

Most indicator wrappers, helper functions, documentation fragments, and
unit tests are generated from the scripts in `codegen/`. The charting
interface is maintained separately.

Common development tasks are exposed through Make targets:

``` sh
make help
```

See CONTRIBUTING.md for the full development workflow.

## Code of Conduct

Please note that [{talib}](https://serkor1.github.io/ta-lib-R/) is
released with a [Contributor Code of
Conduct](https://contributor-covenant.org/version/2/1/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.

[^1]: See `benchmark/` for detailed benchmarks against
    [{TTR}](https://serkor1.github.io/ta-lib-R/) and general performance
    across multiple indicators.

[^2]: [talib](https://serkor1.github.io/ta-lib-R/) is a compiled
    package. CRAN binaries are available for standard platforms when
    provided by CRAN. Source installation requires a working compiler
    toolchain and [CMake](https://cmake.org/).
