# {talib}: R bindings to TA-Lib

[{talib}](https://github.com/serkor1/ta-lib-R/) is an R package for
Technical Analysis (TA) and interactive financial charts. The package is
a wrapper of [TA-Lib](https://github.com/TA-Lib/ta-lib) and supports
over 200 indicators, including candlestick patterns.

## Data format

All functions in [{talib}](https://github.com/serkor1/ta-lib-R/) expect
the input `x` to be coercible to `data.frame` with columns named
according to OHLC-V conventions. The package ships with several built-in
datasets:

``` r

str(talib::BTC)
#> 'data.frame':    366 obs. of  5 variables:
#>  $ open  : num  42274 44185 44966 42863 44191 ...
#>  $ high  : num  44200 45918 45521 44799 44392 ...
#>  $ low   : num  42181 44152 40555 42651 42362 ...
#>  $ close : num  44185 44966 42863 44191 44179 ...
#>  $ volume: num  831 2076 2225 1791 2483 ...
```

### Column names are case-sensitive

Column names **must** be lowercase: `open`, `high`, `low`, `close`, and
`volume`. Names such as `Close`, `CLOSE`, or `Adj.Close` will not be
recognized. If your data uses different names you have two options:
rename the columns, or remap them with the `cols` argument (see [Column
selection with `cols`](#column-selection-with-cols)).

``` r

## rename columns to uppercase;
## this will fail
x <- talib::BTC
colnames(x) <- c("Open", "High", "Low", "Close", "Volume")

talib::RSI(x)
#> Error in `relative_strength_index.default()`:
#> ! Expected to find columns 'close' similar columns found: 'Close'
```

### Not every column is always required

Different indicators use different subsets of the OHLC-V columns. The
table below gives a rough guide:

| Indicator type | Default columns | Example |
|:---|:---|:---|
| Univariate (most) | `close` | [`RSI()`](https://serkor1.github.io/ta-lib-R/reference/relative_strength_index.md), [`SMA()`](https://serkor1.github.io/ta-lib-R/reference/simple_moving_average.md), [`EMA()`](https://serkor1.github.io/ta-lib-R/reference/exponential_moving_average.md) |
| High-Low based | `high + low` | [`SAR()`](https://serkor1.github.io/ta-lib-R/reference/parabolic_stop_and_reverse.md), [`AROON()`](https://serkor1.github.io/ta-lib-R/reference/aroon.md) |
| High-Low-Close | `high + low + close` | [`STOCH()`](https://serkor1.github.io/ta-lib-R/reference/stochastic.md), [`CCI()`](https://serkor1.github.io/ta-lib-R/reference/commodity_channel_index.md), [`ATR()`](https://serkor1.github.io/ta-lib-R/reference/average_true_range.md) |
| Full OHLC | `open + high + low + close` | All candlestick patterns |
| Volume-based | `volume` (+ price columns) | [`OBV()`](https://serkor1.github.io/ta-lib-R/reference/on_balance_volume.md), [`AD()`](https://serkor1.github.io/ta-lib-R/reference/chaikin_accumulation_distribution_line.md), [`MFI()`](https://serkor1.github.io/ta-lib-R/reference/money_flow_index.md) |

A `data.frame` that only contains `high`, `low`, and `close` is
perfectly valid input for
[`STOCH()`](https://serkor1.github.io/ta-lib-R/reference/stochastic.md)
or
[`CCI()`](https://serkor1.github.io/ta-lib-R/reference/commodity_channel_index.md)—columns
that are not needed are simply ignored.

## Computing indicators

### Basic usage

Pass an OHLC-V object directly to any indicator function:

``` r

tail(
    talib::bollinger_bands(talib::BTC)
)
#>                     UpperBand MiddleBand LowerBand
#> 2024-12-26 01:00:00  106053.7   99594.80  93135.86
#> 2024-12-27 01:00:00  106179.5   99305.69  92431.90
#> 2024-12-28 01:00:00  106051.3   99002.74  91954.18
#> 2024-12-29 01:00:00  106223.8   98814.94  91406.11
#> 2024-12-30 01:00:00  106452.7   98613.30  90773.93
#> 2024-12-31 01:00:00  106283.3   98223.05  90162.77
```

All indicator functions follow the same S3 dispatch pattern, with
methods for `data.frame`, `matrix`, `numeric`, and `plotly`. The return
type matches the input type:

``` r

## data.frame in -> data.frame out
class(
    talib::RSI(talib::BTC)
)
#> [1] "data.frame"
```

``` r

## matrix in -> matrix out
class(
    talib::RSI(talib::SPY)
)
#> [1] "matrix" "array"
```

``` r

## numeric vector in -> numeric vector out
is.double(
    talib::RSI(talib::BTC$close)
)
#> [1] TRUE
```

### Function naming

Every indicator has a descriptive snake_case name and an uppercase alias
that mirrors the TA-Lib C function name. Both are interchangeable:

``` r

## these are equivalent
identical(
    talib::relative_strength_index(talib::BTC, timePeriod = 14),
    talib::RSI(talib::BTC, timePeriod = 14)
)
#> [1] TRUE
```

### Lookback and `NA` values

Most indicators require a minimum number of observations before they can
produce a value. This is called the **lookback period**. The first
`lookback` rows of the result will be `NA`:

``` r

## SMA with timePeriod = 5 has a lookback of 4
head(
    talib::SMA(talib::BTC, timePeriod = 5),
    timePeriod = 7
)
#>                          SMA
#> 2024-01-01 01:00:00       NA
#> 2024-01-02 01:00:00       NA
#> 2024-01-03 01:00:00       NA
#> 2024-01-04 01:00:00       NA
#> 2024-01-05 01:00:00 44076.95
#> 2024-01-06 01:00:00 44038.77
```

The lookback is stored as an attribute on the result:

``` r

x <- talib::SMA(talib::BTC, timePeriod = 20)
attr(x, "lookback")
#> [1] 19
```

## Column selection with `cols`

The `cols` argument accepts a one-sided formula (`~`) that selects which
columns to use for the calculation. Every indicator has a sensible
default, but `cols` lets you override it.

### Univariate indicators

For indicators that operate on a single series (e.g., `RSI`, `SMA`), the
default is `~close`. Pass a different column to calculate the indicator
on that series instead:

``` r

## RSI on 'high' instead of 'close'
tail(
    talib::RSI(talib::BTC, cols = ~high)
)
#>                          RSI
#> 2024-12-26 01:00:00 50.88773
#> 2024-12-27 01:00:00 45.83913
#> 2024-12-28 01:00:00 42.51414
#> 2024-12-29 01:00:00 41.80903
#> 2024-12-30 01:00:00 41.33147
#> 2024-12-31 01:00:00 44.58689
```

### Multivariate indicators

For indicators that require multiple columns, `cols` remaps which
columns are used. The order in the formula must match the order expected
by the indicator:

``` r

## Stochastic defaults to ~high + low + close;
## here we swap 'close' for 'open'
tail(
    talib::STOCH(
        talib::BTC,
        cols = ~high + low + open
    )
)
#>                        SlowK    SlowD
#> 2024-12-26 01:00:00 71.97751 51.79551
#> 2024-12-27 01:00:00 74.68050 65.64619
#> 2024-12-28 01:00:00 49.96515 65.54105
#> 2024-12-29 01:00:00 29.80067 51.48210
#> 2024-12-30 01:00:00 23.91322 34.55968
#> 2024-12-31 01:00:00 26.81634 26.84341
```

### Extra arguments via `...`

Additional arguments are forwarded to
[`model.frame()`](https://rdrr.io/r/stats/model.frame.html). This is
useful for computing an indicator on a subset of the data:

``` r

## Bollinger Bands on the first 100 rows only
tail(
    talib::BBANDS(
        talib::BTC,
        subset = 1:nrow(talib::BTC) %in% 1:100
    )
)
#>                     UpperBand MiddleBand LowerBand
#> 2024-04-04 02:00:00  72705.46   67602.15  62498.83
#> 2024-04-05 02:00:00  72720.81   67732.01  62743.21
#> 2024-04-06 02:00:00  72768.11   67759.82  62751.52
#> 2024-04-07 02:00:00  72902.87   67847.32  62791.77
#> 2024-04-08 02:00:00  72849.23   68333.52  63817.81
#> 2024-04-09 02:00:00  72920.00   68397.21  63874.42
```

## Handling missing values with `na.bridge`

Real-world data often contains missing values. By default
(`na.bridge = FALSE`), any `NA` in the input propagates through the
entire calculation, which can fill the result with `NA`s.

Setting `na.bridge = TRUE` strips `NA` rows before calculation, computes
the indicator on the clean data, and then re-inserts `NA`s at their
original positions:

``` r

## inject some NAs
x <- talib::BTC
x$close[c(10, 50, 100)] <- NA
```

``` r

## default: NAs propagate
sum(is.na(
    talib::RSI(x)
))
#> [1] 366
```

``` r

## na.bridge = TRUE: NAs are skipped
sum(is.na(
    talib::RSI(x, na.bridge = TRUE)
))
#> [1] 17
```

The stripped rows are restored in the output, so the result always has
the same number of rows as the input:

``` r

nrow(talib::RSI(x, na.bridge = TRUE)) == nrow(x)
#> [1] TRUE
```

## Moving Average specifications

Several indicators accept a **Moving Average specification** for their
smoothing component. MA functions such as
[`SMA()`](https://serkor1.github.io/ta-lib-R/reference/simple_moving_average.md),
[`EMA()`](https://serkor1.github.io/ta-lib-R/reference/exponential_moving_average.md),
[`WMA()`](https://serkor1.github.io/ta-lib-R/reference/weighted_moving_average.md),
[`DEMA()`](https://serkor1.github.io/ta-lib-R/reference/double_exponential_moving_average.md),
[`TEMA()`](https://serkor1.github.io/ta-lib-R/reference/triple_exponential_moving_average.md),
[`TRIMA()`](https://serkor1.github.io/ta-lib-R/reference/triangular_moving_average.md),
[`KAMA()`](https://serkor1.github.io/ta-lib-R/reference/kaufman_adaptive_moving_average.md),
and
[`T3()`](https://serkor1.github.io/ta-lib-R/reference/t3_exponential_moving_average.md)
serve a dual purpose:

- **With `x`**: compute the Moving Average on the data.
- **Without `x`**: return a specification (a named list) that other
  indicators use internally.

``` r

## SMA as a specification
str(
    talib::SMA(timePeriod = 20)
)
#> List of 2
#>  $ timePeriod: int 20
#>  $ maType    : int 0
#>  - attr(*, "class")= chr "maType"
```

This specification can be passed to indicators like
[`bollinger_bands()`](https://serkor1.github.io/ta-lib-R/reference/bollinger_bands.md)
or
[`stochastic()`](https://serkor1.github.io/ta-lib-R/reference/stochastic.md)
to control the type of smoothing:

``` r

## Bollinger Bands with an EMA(20) middle band
tail(
    talib::bollinger_bands(
        talib::BTC,
        timePeriod = 20,
        maType = talib::EMA()
    )
)
#>                     UpperBand MiddleBand LowerBand
#> 2024-12-26 01:00:00  104645.9   98186.94  91727.99
#> 2024-12-27 01:00:00  104677.9   97804.16  90930.38
#> 2024-12-28 01:00:00  104597.2   97548.60  90500.04
#> 2024-12-29 01:00:00  104577.9   97169.11  89760.28
#> 2024-12-30 01:00:00  104576.0   96736.62  88897.26
#> 2024-12-31 01:00:00  104478.2   96417.96  88357.68
```

``` r

## Stochastic with WMA smoothing
tail(
    talib::stochastic(
        talib::BTC,
        slowKPeriod = 5,
        slowKMa = talib::EMA(),
        slowDPeriod = 5,
        slowDMa = talib::EMA()
    )
)
#>                        SlowK    SlowD
#> 2024-12-26 01:00:00 57.95326 52.08347
#> 2024-12-27 01:00:00 46.58872 50.25188
#> 2024-12-28 01:00:00 40.20738 46.90372
#> 2024-12-29 01:00:00 30.26784 41.35843
#> 2024-12-30 01:00:00 25.30502 36.00729
#> 2024-12-31 01:00:00 28.28073 33.43177
```

## Candlestick pattern recognition

Candlestick pattern functions return an integer `matrix`: `1` for
bullish, `-1` for bearish, and `0` for no pattern. The encoding can be
changed via `options(talib.normalize = FALSE)` to use `100`/`-100`
instead.

``` r

x <- talib::harami(talib::BTC)
tail(x)
#>                     CDLHARAMI
#> 2024-12-26 01:00:00         0
#> 2024-12-27 01:00:00         0
#> 2024-12-28 01:00:00         0
#> 2024-12-29 01:00:00         0
#> 2024-12-30 01:00:00         0
#> 2024-12-31 01:00:00         0
```

``` r

## find all bullish occurrences
talib::BTC[which(x == 1), ]
#> [1] open   high   low    close  volume
#> <0 rows> (or 0-length row.names)
```

> **Note:** For a detailed treatment of candlestick lookback and
> sensitivity parameters, see
> [`vignette("candlestick", package = "talib")`](https://serkor1.github.io/ta-lib-R/articles/candlestick.md).

## Charting

The package includes interactive charting built on
[{plotly}](https://github.com/plotly/plotly.R). The two main functions
are [`chart()`](https://serkor1.github.io/ta-lib-R/reference/chart.md)
and
[`indicator()`](https://serkor1.github.io/ta-lib-R/reference/indicator.md),
which work like [`plot()`](https://rdrr.io/r/graphics/plot.default.html)
and [`lines()`](https://rdrr.io/r/graphics/lines.html):

``` r

{
    ## main candlestick chart
    talib::chart(talib::BTC)

    ## add Bollinger Bands
    talib::indicator(talib::bollinger_bands)

    ## add identified Harami patterns
    talib::indicator(talib::harami)

    ## add MACD as a sub-chart
    talib::indicator(talib::MACD)
}
```

[`indicator()`](https://serkor1.github.io/ta-lib-R/reference/indicator.md)
automatically determines whether a given indicator belongs on the main
price chart (e.g., Bollinger Bands, SAR) or as a sub-chart (e.g., RSI,
MACD).

> **Note:** For themes, chart options, and advanced charting, see
> [`vignette("charting", package = "talib")`](https://serkor1.github.io/ta-lib-R/articles/charting.md).

## Contributing and bug reports

The underlying library, [TA-Lib](https://github.com/TA-Lib/ta-lib), is a
long-standing and well-known library but this R wrapper is still in its
early stage. All contributions, suggestions, and bug reports are
welcome.
