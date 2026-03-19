# Interactive Financial Charts

## Price Charts

### Candlestick Chart

``` r
talib::chart(
  x = talib::NVDA,
  type = "candlestick"
)
```

### OHLC Chart

``` r
talib::chart(
  x = talib::BTC,
  type = "ohlc"
)
```

By default the `chart`-function inherits name of the argument `x` as the
title. This can be modified via the `title`-argument.

``` r
talib::chart(
  x = talib::BTC,
  type = "ohlc",
  title = "SPDR S&P 500 ETF Trust"
)
```

## Charting indicators

The various indicators can be added to the price chart—or charted
seperately—with the `indicator`-function. The `indicator`-function will
attach itself to the last chart.

``` r
talib::indicator(
    FUN = talib::MACD
)
```

If you have already called the `chart`-function, and want to plot the
indicator seperately you will have to clear the existing chart—this is
done by calling
[`talib::chart()`](https://serkor1.github.io/ta-lib-R/reference/chart.md)
without any arguments. The indicator can now be re-charted using the
`indicator`-function.

``` r
{
  ## clear the chart
  ## by calling talib::chart()
  ## without any arguments
  talib::chart()

  ## rechart the indicator
  ## directly
  talib::indicator(
    FUN = talib::MACD,
    data = talib::BTC
  )
}
```

Notice here that you have to pass a `data` argument via `...` which gets
passed downstream to `MACD`.

## Modifying charts

The charts can be globally modified via `options` use
[`?talib::chart`](https://serkor1.github.io/ta-lib-R/reference/chart.md)
to see the full range of modifications available for the charting. Below
is an example on how to modify the color scheme of the charts.

### chart themes

``` r
{
  talib::chart(talib::BTC)
  talib::indicator(talib::SMA, n = 7)
  talib::indicator(talib::SMA, n = 14)
  talib::indicator(talib::SMA, n = 21)
  talib::indicator(talib::SMA, n = 28)
  talib::indicator(talib::MACD)
  talib::indicator(talib::trading_volume)
}
```

``` r
{
  talib::set_theme$hawks_and_doves()
  talib::chart(talib::BTC)
  talib::indicator(talib::SMA, n = 7)
  talib::indicator(talib::SMA, n = 14)
  talib::indicator(talib::SMA, n = 21)
  talib::indicator(talib::SMA, n = 28)
  talib::indicator(talib::MACD)
  talib::indicator(talib::trading_volume)
}
```

``` r
{
  talib::set_theme$payout()
  talib::chart(talib::BTC)
  talib::indicator(talib::SMA, n = 7)
  talib::indicator(talib::SMA, n = 14)
  talib::indicator(talib::SMA, n = 21)
  talib::indicator(talib::SMA, n = 28)
  talib::indicator(talib::MACD)
  talib::indicator(talib::trading_volume)
}
```

``` r
{
  talib::set_theme$tp_slapped()
  talib::chart(talib::BTC)
  talib::indicator(talib::SMA, n = 7)
  talib::indicator(talib::SMA, n = 14)
  talib::indicator(talib::SMA, n = 21)
  talib::indicator(talib::SMA, n = 28)
  talib::indicator(talib::MACD)
  talib::indicator(talib::trading_volume)
}
```

``` r
{
  talib::set_theme$trust_the_process()
  talib::chart(talib::BTC)
  talib::indicator(talib::SMA, n = 7)
  talib::indicator(talib::SMA, n = 14)
  talib::indicator(talib::SMA, n = 21)
  talib::indicator(talib::SMA, n = 28)
  talib::indicator(talib::MACD)
  talib::indicator(talib::trading_volume)
}
```

``` r
## modify options
## to create charts in
## light and color-deficiency mode
options(
  talib.chart.dark = FALSE,
  talib.chart.deficieny = TRUE
)

{
  ## price chart
  ## with defaults
  talib::chart(
    talib::SPY
  )

  ## add RSI indicator
  talib::indicator(
    FUN = talib::RSI
  )

  ## add Bollinger Bands
  talib::indicator(
    FUN = talib::BBANDS
  )
  
}
```

### Modifying x-axis labels

Internally
[`chart()`](https://serkor1.github.io/ta-lib-R/reference/chart.md) and
[`indicator()`](https://serkor1.github.io/ta-lib-R/reference/indicator.md)
are working on the range of the the data—ie. `1:nrow(data)`—to easy the
process of subsetting and for the efficiency. The x-axis can be labelled
with dates from the data via the `idx`-argument.

``` r
{
  talib::chart(
    x = talib::BTC,
    idx = rownames(talib::BTC)
  )
}
```

### Charting Subsets

The downstream indicator functions uses `model.frame` as the main
function. This is useful in cases where the interest lies in indicators
across a specific range without wanting to subset the data itself, or if
you want to change indicators over time.

``` r
{
  talib::chart(
    x = talib::BTC,
    idx = rownames(talib::BTC)
  )

  talib::indicator(
    talib::BBANDS,
    subset = 1:nrow(talib::BTC) %in% c(50:100)
  )

  talib::indicator(
    talib::ACCBANDS,
    subset = 1:nrow(talib::BTC) %in% c(101:151)
  )
}
```
