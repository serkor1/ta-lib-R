# Cross Series

Identifies where `shortSeries` crosses `longSeries` in either direction.
A cross over is emitted as `1` and a cross under as `-1`, so the result
equals the sum of
[`cross_over()`](https://serkor1.github.io/ta-lib-R/reference/cross_over.md)
and
[`cross_under()`](https://serkor1.github.io/ta-lib-R/reference/cross_under.md).

Both comparisons are strict, so a series that only touches `longSeries`
is not a crossing.

## Usage

``` r
cross_series(shortSeries, longSeries, na.rm = FALSE)
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
where `shortSeries` crosses over `longSeries`, `-1` where it crosses
under and `0` otherwise. The first element is always
[NA](https://rdrr.io/r/base/NA.html) as it has no previous bar.

## See also

Other Signals:
[`cross_over()`](https://serkor1.github.io/ta-lib-R/reference/cross_over.md),
[`cross_under()`](https://serkor1.github.io/ta-lib-R/reference/cross_under.md)

## Author

Serkan Korkmaz

## Examples

``` r
## short moving average crossing
## a long moving average
talib::cross_series(
  talib::SMA(talib::BTC$close, timePeriod = 10),
  talib::SMA(talib::BTC$close, timePeriod = 30)
)
#>   [1] NA  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0
#>  [26]  0  0  0  0  0  0  0  0  0  0  1  0  0  0  0  0  0  0  0  0  0  0  0  0  0
#>  [51]  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0
#>  [76]  0  0  0  0  0  0  0  0  0  0  0  0 -1  1  0  0  0  0  0  0  0  0  0  0  0
#> [101]  0  0  0  0  0  0 -1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0
#> [126]  0  0  0  0  0  0  0  0  0  0  0  0  0  1  0  0  0  0  0  0  0  0  0  0  0
#> [151]  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 -1  0  0  0  0  0  0  0  0
#> [176]  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0
#> [201]  1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 -1  0  0  0  0  0  0
#> [226]  0  0  0  0  0  0  0  0  0  0  0  0  0  1  0  0  0  0  0  0  0  0 -1  0  0
#> [251]  0  0  0  0  0  0  0  0  0  0  0  0  1  0  0  0  0  0  0  0  0  0  0  0  0
#> [276]  0  0  0  0  0  0  0 -1  0  0  0  0  0  1  0  0  0  0  0  0  0  0  0  0  0
#> [301]  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0
#> [326]  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0
#> [351]  0  0  0  0  0  0  0  0  0  0 -1  0  0  0  0  0
```
