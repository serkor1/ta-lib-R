# {talib}: R bindings to TA-Lib

[{talib}](https://github.com/serkor1/ta-lib-R/) is an R package for
Technical Analysis (TA) and interactive financial charts. The package is
a wrapper of [TA-Lib](https://github.com/TA-Lib/ta-lib) and supports
over 200 indicators, including candlestick patterns.

## Basic usage

In this section I will show how to calculate and chart different
indicators using Bitcoin (BTC). BTC is a built-in `data.frame` using the
[{cryptoQuotes}](https://github.com/serkor1/cryptoQuotes)-package and
has the following form:

``` r
str(
    talib::BTC
)
#> 'data.frame':    366 obs. of  5 variables:
#>  $ open  : num  42274 44185 44966 42863 44191 ...
#>  $ high  : num  44200 45918 45521 44799 44392 ...
#>  $ low   : num  42181 44152 40555 42651 42362 ...
#>  $ close : num  44185 44966 42863 44191 44179 ...
#>  $ volume: num  831 2076 2225 1791 2483 ...
```

The focus of this section will be Bollinger Bands and Harami patterns.
All remaining indicators and candlestick patterns behaves in the same
manner.

> **NOTE:** All functions expects that a permutation of either `open`,
> `high`, `low`, `close` and/or `volume` exists (case sensitive). But
> this depends on the specific functions; for indicators that only uses
> `high` and `low`, the remaining columns needs not to be present in the
> data. Column names must follow OHLC-V conventions unless remapped via
> the `cols`-argument.

### Indicators

All indicator functions in
[{talib}](https://github.com/serkor1/ta-lib-R/) assumes that the input
argument `x` is an OHLC-V object coercible to `data.frame`; the `BTC`
can passed directly into the function:

``` r
{
    cat("Bollinger Bands")
    tail(
        talib::bollinger_bands(
            x = talib::BTC
        )
    )
}
#> Bollinger Bands
#>                     UpperBand MiddleBand LowerBand
#> 2024-12-26 01:00:00 104478.35   98217.88  91957.42
#> 2024-12-27 01:00:00 100877.73   97020.16  93162.59
#> 2024-12-28 01:00:00  99886.22   96516.01  93145.81
#> 2024-12-29 01:00:00  99871.12   96134.41  92397.71
#> 2024-12-30 01:00:00  99713.92   95620.42  91526.92
#> 2024-12-31 01:00:00  99373.89   95236.42  91098.95
```

Internally,
[`bollinger_bands()`](https://serkor1.github.io/ta-lib-R/reference/bollinger_bands.md)
calls `model.frame` with a prespecified `formula` corresponding to the
default calculation method of the indicator. You can modify this by
passing a different variable through the `cols`-argument as follows:

``` r
{
    cat("Bollinger Bands")
    tail(
        talib::bollinger_bands(
            x = talib::BTC,
            cols = ~high
        )
    )
}
#> Bollinger Bands
#>                     UpperBand MiddleBand LowerBand
#> 2024-12-26 01:00:00  108202.2  100799.26  93396.27
#> 2024-12-27 01:00:00  105337.0   99701.75  94066.50
#> 2024-12-28 01:00:00  102506.4   98606.20  94705.95
#> 2024-12-29 01:00:00  101126.9   97847.80  94568.70
#> 2024-12-30 01:00:00  101232.6   97525.44  93818.30
#> 2024-12-31 01:00:00  100720.8   97187.48  93654.11
```

The Harami pattern, and all candlestick patterns in general, returns a
`matrix` of \<integers\>: -1 for bearish patterns, 1 for bullish pattern
and 0 for no pattern. See below:

``` r
{
    cat("Harami Patterns")
    tail(
        talib::harami(
            talib::BTC
        )
    )
}
#> Harami Patterns
#>                     CDLHARAMI
#> 2024-12-26 01:00:00         0
#> 2024-12-27 01:00:00         0
#> 2024-12-28 01:00:00         0
#> 2024-12-29 01:00:00         0
#> 2024-12-30 01:00:00         0
#> 2024-12-31 01:00:00         0
```

The pattern is rare, so let us find occurrences instead:

``` r
## assign the Harami
## pattern
x <- talib::harami(
    talib::BTC
)
```

``` r
## locate bullish Harami
## patterns
{
    cat("Bullish Harami")
    talib::BTC[
        which(x == 1),
    ]
}
#> Bullish Harami
#>                         open     high      low    close    volume
#> 2024-01-13 01:00:00 42770.74 43244.75 42417.54 42842.43 1389.8450
#> 2024-01-19 01:00:00 41286.00 42144.29 40250.00 41622.00 2204.1180
#> 2024-01-23 01:00:00 39521.03 40135.90 38508.01 39871.07 1691.9766
#> 2024-03-06 01:00:00 63803.50 67655.97 62834.01 66112.32 2152.6899
#> 2024-04-03 02:00:00 65477.34 66944.00 64500.00 65986.02  730.2592
#> 2024-04-16 02:00:00 63449.24 64392.44 61641.34 63820.00  975.8047
#> 2024-05-02 02:00:00 58267.89 59638.02 56893.92 59066.67 1608.7340
#> 2024-06-27 02:00:00 60828.18 62346.00 60559.38 61629.99 1343.3199
#> 2024-12-20 01:00:00 97385.63 98138.88 92129.00 97767.96 6001.8659
```

``` r
## locate bearish Harami
## patterns
{
    cat("Bearish Harami")
    talib::BTC[
        which(x == -1),
    ]
}
#> Bearish Harami
#>                         open      high      low    close     volume
#> 2024-02-29 01:00:00 62501.89  63687.68 60288.00 61176.09  1673.0354
#> 2024-03-18 01:00:00 68343.73  68916.00 66500.00 67607.98   982.5063
#> 2024-03-21 01:00:00 67843.99  68251.55 64500.00 65485.53  1852.2649
#> 2024-04-23 02:00:00 66836.51  67215.98 65824.00 66420.00   642.0294
#> 2024-08-07 02:00:00 56047.14  57757.99 54576.39 55147.74  3693.4807
#> 2024-08-09 02:00:00 61705.24  61763.99 59562.44 60866.00  3009.3530
#> 2024-09-14 02:00:00 60541.13  60668.00 59417.53 60011.32  1862.7975
#> 2024-10-30 01:00:00 72724.97  72950.00 71400.01 72329.01  2844.8865
#> 2024-11-28 01:00:00 95957.53  96667.16 94658.27 95663.18  2634.8156
#> 2024-12-05 01:00:00 98740.11 104149.99 91500.00 97050.01 13774.3383
```

### Charting indicators

In this section I will focus on the basics of charting. The charting
uses [{plotly}](https://github.com/plotly/plotly.R) internally which
also enables manual drawing of support and resistance lines.

> **Information:** Please refer to
> [`vignette(topic = "charting", package = "talib")`](https://serkor1.github.io/ta-lib-R/articles/charting.md)
> for a more detailed description of the charting.

The charting functionality mimicks the behaviour of
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) and
[`lines()`](https://rdrr.io/r/graphics/lines.html) where each is called
separately. There are two main charting functions in
[{talib}](https://github.com/serkor1/ta-lib-R/):
[`chart()`](https://serkor1.github.io/ta-lib-R/reference/chart.md) and
[`indicator()`](https://serkor1.github.io/ta-lib-R/reference/indicator.md).
Below I will expand the analysis by adding Moving Average
Convergence/Divergence indicators to the chart:

``` r
{
    ## main candlestick
    ## chart
    talib::chart(
        talib::BTC
    )

    ## add bollinger bands
    ## to the chart
    talib::indicator(
        talib::bollinger_bands
    )

    ## add identified harami
    ## patterns
    talib::indicator(
        talib::harami
    )

    ## add moving average
    ## convergence/divergence
    ## to the chart
    talib::indicator(
        talib::moving_average_convergence_divergence
    )
}
```

One thing to note here is that
[`indicator()`](https://serkor1.github.io/ta-lib-R/reference/indicator.md)
internally calls the
[{plotly}](https://github.com/plotly/plotly.R)-methods for each
indicator which determines whether the indicator is main-chart indicator
or sub-chart indicator.

## Contributing and bug reports

The underlying library, [TA-Lib](https://github.com/TA-Lib/ta-lib), is a
long-standing and well-known library but this R wrapper is still in its
early stage. All contributions, suggestions, and bug reports are
welcome.
