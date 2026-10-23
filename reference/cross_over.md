# Cross Over

Identifies where `shortSeries` crosses `longSeries` from below, i.e.
where `shortSeries` was below `longSeries` on the previous bar and is
above it on the current bar. A typical use is a short moving average
crossing over a long moving average, or an oscillator crossing over a
threshold.

Both comparisons are strict, so a series that only touches `longSeries`
is not a crossing.

## Usage

``` r
cross_over(shortSeries, longSeries, na.rm = FALSE)
```

## Arguments

- shortSeries:

  An [integer](https://rdrr.io/r/base/integer.html) or
  [double](https://rdrr.io/r/base/double.html) vector.

- longSeries:

  An [integer](https://rdrr.io/r/base/integer.html) or
  [double](https://rdrr.io/r/base/double.html) vector of the same
  [length](https://rdrr.io/r/base/length.html) as `shortSeries`, or of
  [length](https://rdrr.io/r/base/length.html) 1 to compare against a
  fixed level.

- na.rm:

  A [logical](https://rdrr.io/r/base/logical.html) of
  [length](https://rdrr.io/r/base/length.html) 1. If `TRUE`, a crossing
  that involves a missing value on either bar is returned as
  [NA](https://rdrr.io/r/base/NA.html). If `FALSE` (default), missing
  values are not checked and such bars are returned as `0`.

## Value

An [integer](https://rdrr.io/r/base/integer.html) vector of the same
[length](https://rdrr.io/r/base/length.html) as `shortSeries` with `1`
where `shortSeries` crosses over `longSeries` and `0` otherwise. The
first element is always [NA](https://rdrr.io/r/base/NA.html) as it has
no previous bar.

## See also

Other Signals:
[`cross_series()`](https://serkor1.github.io/ta-lib-R/reference/cross_series.md),
[`cross_under()`](https://serkor1.github.io/ta-lib-R/reference/cross_under.md)

## Author

Serkan Korkmaz

## Examples

``` r
## short moving average crossing
## over a long moving average
talib::cross_over(
  talib::SMA(talib::BTC$close, timePeriod = 10),
  talib::SMA(talib::BTC$close, timePeriod = 30)
)
#>   [1] NA  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0
#>  [26]  0  0  0  0  0  0  0  0  0  0  1  0  0  0  0  0  0  0  0  0  0  0  0  0  0
#>  [51]  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0
#>  [76]  0  0  0  0  0  0  0  0  0  0  0  0  0  1  0  0  0  0  0  0  0  0  0  0  0
#> [101]  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0
#> [126]  0  0  0  0  0  0  0  0  0  0  0  0  0  1  0  0  0  0  0  0  0  0  0  0  0
#> [151]  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0
#> [176]  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0
#> [201]  1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0
#> [226]  0  0  0  0  0  0  0  0  0  0  0  0  0  1  0  0  0  0  0  0  0  0  0  0  0
#> [251]  0  0  0  0  0  0  0  0  0  0  0  0  1  0  0  0  0  0  0  0  0  0  0  0  0
#> [276]  0  0  0  0  0  0  0  0  0  0  0  0  0  1  0  0  0  0  0  0  0  0  0  0  0
#> [301]  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0
#> [326]  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0
#> [351]  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0

## RSI crossing over 30
talib::cross_over(
  talib::RSI(talib::BTC$close),
  30
)
#>   [1] NA  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0
#>  [26]  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0
#>  [51]  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0
#>  [76]  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0
#> [101]  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0
#> [126]  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0
#> [151]  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0
#> [176]  0  1  0  0  0  0  0  0  0  0  0  0  1  0  0  0  0  0  0  0  0  0  0  0  0
#> [201]  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  1  0  0  0  0  0  0
#> [226]  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0
#> [251]  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0
#> [276]  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0
#> [301]  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0
#> [326]  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0
#> [351]  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0
```
