# Candlestick Pattern Recognition

In this vignette I demonstrate how to identify Japanese candlestick
patterns on cryptocurrency OHLC data using Bitcoin (BTC) from the
[{cryptoQuotes}](https://github.com/serkor1/cryptoQuotes)-package.

``` r
str(talib::BTC)
#> 'data.frame':    366 obs. of  5 variables:
#>  $ open  : num  42274 44185 44966 42863 44191 ...
#>  $ high  : num  44200 45918 45521 44799 44392 ...
#>  $ low   : num  42181 44152 40555 42651 42362 ...
#>  $ close : num  44185 44966 42863 44191 44179 ...
#>  $ volume: num  831 2076 2225 1791 2483 ...
```

I begin with a short primer on candlestick construction. I then define
two key control parameters for pattern recognition—`lookbacks` (how many
prior bars a rule may inspect) and `sensitivity` (how strict the rule is
with respect to body/shadow proportions). I finish with charting the
patterns, and give short intepretation of it.

## A primer on Candlestick Patterns

A candlestick shows four prices for a chosen time period: Open, High,
Low, and Close (OHLC).

The real body is the segment between the Open and the Close. If the
Close is above the Open, the candle is bullish; if the Close is below
the Open, the candle is bearish. Charting platforms typically color
bullish candles green or hollow and bearish candles red or filled, but
the color scheme is platform specific.

The line from the high down to the top of the real body is the upper
shadow; the line from the low up to the bottom of the real body is the
lower shadow. Together they show the price extremes outside the
Open-Close range.

Candlestick patterns are built from one or more candles by comparing the
size and position of bodies and shadows relative to each other and to
the recent trend.

## Candlestick patterns in [{talib}](https://serkor1.github.io/ta-lib-R/)

In this section I will focus on three patterns:
[`doji()`](https://serkor1.github.io/ta-lib-R/reference/doji.md),
[`harami()`](https://serkor1.github.io/ta-lib-R/reference/harami.md) and
[`three_outside()`](https://serkor1.github.io/ta-lib-R/reference/three_outside.md).
I will start identifying them with the default `lookback` and
`sensitivity`, and then modify the parameters individually to
demonstrate how it affects the number of identified patterns.

``` r
## construct data.frame
## with default lookback
## and sensitivity
x <- cbind(
    talib::doji(talib::BTC),
    talib::harami(talib::BTC),
    talib::three_outside(talib::BTC)
)
```

Each function returns a matrix of `<integer>`: -1 for an identified
bearish pattern, 1 for an identified (possibly) bullish pattern and 0
for no identified pattern. In this vignette we focus on identified
patterns, and therefore only summarize the absolute values.

> **NOTE:** Some patterns are neither inherently bullish or bearish, and
> such patterns will *always* be 1 for identified patterns. A negative
> value is *always* bearish.

The identified patterns can be summarized as follows:

``` r
{
    cat("With default options\n")
    apply(abs(x), 2, sum, na.rm = TRUE)
}
#> With default options
#>     CDLDOJI   CDLHARAMI CDL3OUTSIDE 
#>          56          19          21
```

The default settings identified 62, 21 and 21 Doji, Harami and Three
Outside patterns. There are an important aspect to take note of here:
`<NA>`-values.

The `<NA>`-values are a byproduct of the underlying algorithms in
identifying the patterns. The
[`doji()`](https://serkor1.github.io/ta-lib-R/reference/doji.md), for
example, uses a default lookback period of 10 candles in identifying the
pattern—and therefore discards the first 10 values. The same logic
applies for
[`harami()`](https://serkor1.github.io/ta-lib-R/reference/harami.md) and
[`three_outside()`](https://serkor1.github.io/ta-lib-R/reference/three_outside.md).

### Candle inclusion (lookback)

The default number of candles used to identify a specific can be
modified with [`options()`](https://rdrr.io/r/base/options.html). The
[`doji()`](https://serkor1.github.io/ta-lib-R/reference/doji.md) and
[`harami()`](https://serkor1.github.io/ta-lib-R/reference/harami.md)
depends on the candle bodies which can be modified as follows:

``` r
## set included number
## of candles
options(
    talib.BodyDoji.N  = 5,
    talib.BodyLong.N  = 7,
    talib.BodyShort.N = 7
)
```

To determine whether the real body is that of a Doji, it will now use
the past 5 candles, instead of the default 10 candles. And similarly it
will use the past 7 candles to determine if the real body is long or
short. The identified patterns can be summarized as follows:

``` r
{
    cat("With modified lookback\n")
    apply(abs(x), 2, sum, na.rm = TRUE)
}
#> With modified lookback
#>     CDLDOJI   CDLHARAMI CDL3OUTSIDE 
#>          62          21          21
```

By modifying the settings 62, 21 and 21 Doji, Harami and Three Outside
patterns. Notice that the Three Outside pattern did not change; this is
because the pattern *always* needs three candles to be identified.

### Candle sensitivity

Before proceeding to analyze candle sensitivity, I set the candlestick
lookbacks to its default values:

``` r
## default values
options(
    talib.BodyDoji.N = 10,
    talib.BodyLong.N = 10,
    talib.BodyShort.N = 10
)
```

Candle sensitivity in [{talib}](https://serkor1.github.io/ta-lib-R) is a
sensitivity factor that multiplies the reference value from the previous
N candles (lookback); the current candle is tested against
$\alpha \times reference$. A smaller $\alpha$ makes the condition harder
to satisfy.

The sensitivity can be modified as follows:

``` r
## set sensitivity
## of candles
options(
    talib.BodyDoji.alpha = 0.2
)
```

The identified patterns can be summarized as follows:

``` r
{
    cat("With modified sensitivity options\n")
    apply(abs(x), 2, sum, na.rm = TRUE)
}
#> With modified sensitivity options
#>     CDLDOJI   CDLHARAMI CDL3OUTSIDE 
#>         109          19          21
```

The default setting for
[`doji()`](https://serkor1.github.io/ta-lib-R/reference/doji.md) is 0.1,
and setting this value higher increases the identified number of
Doji-patterns to 109. In this case the 0.2 value translates to the
following:

> Real body is like Doji’s body when it’s shorter than 20% the average
> of the 10 previous candles’ high-low range.

### Charting

The candlestick patterns can be charted similar to the remaining
indicators in [{talib}](https://serkor1.github.io/ta-lib-R/).

``` r
{
    ## candlestick chart
    talib::chart(talib::BTC)

    ## chart identified 'doji'-patterns
    talib::indicator(talib::doji)

    ## chart identified 'harami'-patterns
    talib::indicator(talib::harami)

    ## chart identified 'three outside'-patterns
    talib::indicator(talib::three_outside)
}
```

Identified patterns that are neither bullish or bearish are colored in a
neutral way, while bullish or bearish patterns follows the typical color
conventions.

## Contributing and bug reports

The underlying library, [TA-Lib](https://github.com/TA-Lib/ta-lib), is a
long-standing and well-known library but this R wrapper is still in its
early stage. All contributions, suggestions, and bug reports are
welcome.
