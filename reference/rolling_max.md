# Rolling Max

The `rolling_max()` is a generic S3 function that builds upon
'type-safe'-esque workflows limited to classes in in base `R`, and the
package-wide dependencies. Ie.
[class](https://rdrr.io/r/base/class.html) in,
[class](https://rdrr.io/r/base/class.html) out.

### Handling of -values

`rolling_max()` iterates over valid values, and returns `NA` for the
remaing part of series.

## Usage

``` r
rolling_max(x, n = 10)
```

## Arguments

- x:

  ([double](https://rdrr.io/r/base/double.html)). A vector.

- n:

  ([integer](https://rdrr.io/r/base/integer.html)). An
  [integer](https://rdrr.io/r/base/integer.html) of
  [length](https://rdrr.io/r/base/length.html) 1.

## Value

A [double](https://rdrr.io/r/base/double.html) vector with the same
[length](https://rdrr.io/r/base/length.html) of `x`

## See also

Other Rolling Statistic:
[`rolling_beta()`](https://serkor1.github.io/ta-lib-R/reference/rolling_beta.md),
[`rolling_correlation()`](https://serkor1.github.io/ta-lib-R/reference/rolling_correlation.md),
[`rolling_min()`](https://serkor1.github.io/ta-lib-R/reference/rolling_min.md),
[`rolling_standard_deviation()`](https://serkor1.github.io/ta-lib-R/reference/rolling_standard_deviation.md),
[`rolling_sum()`](https://serkor1.github.io/ta-lib-R/reference/rolling_sum.md),
[`rolling_variance()`](https://serkor1.github.io/ta-lib-R/reference/rolling_variance.md)

## Author

Serkan Korkmaz

## Examples

``` r
## load Bitcoin (BTC)
## series
data(BTC, package = "talib")

## calculate the indicator
## Open
output <- talib::rolling_max(x = BTC[[1]])

## display the results
utils::tail(output)
#> [1] 106136.9 106136.9 100146.7  99356.0  99356.0  99356.0
```
