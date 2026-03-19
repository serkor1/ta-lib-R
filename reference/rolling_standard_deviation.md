# Rolling Standard Deviation

The `rolling_standard_deviation()` is a generic S3 function that builds
upon 'type-safe'-esque workflows limited to classes in in base `R`, and
the package-wide dependencies. Ie.
[class](https://rdrr.io/r/base/class.html) in,
[class](https://rdrr.io/r/base/class.html) out.

### Handling of -values

`rolling_standard_deviation()` iterates over valid values, and returns
`NA` for the remaing part of series.

## Usage

``` r
rolling_standard_deviation(x, n = 10, k = 1, na.ignore = FALSE)
```

## Arguments

- x:

  ([double](https://rdrr.io/r/base/double.html)). A vector.

- n:

  ([integer](https://rdrr.io/r/base/integer.html)). An
  [integer](https://rdrr.io/r/base/integer.html) of
  [length](https://rdrr.io/r/base/length.html) 1.

- k:

  ([double](https://rdrr.io/r/base/double.html)). Multiplier for the
  standard deviation.

- na.ignore:

  ([logical](https://rdrr.io/r/base/logical.html)). A
  [logical](https://rdrr.io/r/base/logical.html) of
  [length](https://rdrr.io/r/base/length.html) 1.
  [FALSE](https://rdrr.io/r/base/logical.html) by default. If
  [TRUE](https://rdrr.io/r/base/logical.html) 's are ignored during
  calculation to avoid returning `x` filled with 's.

## Value

A [double](https://rdrr.io/r/base/double.html) vector with the same
[length](https://rdrr.io/r/base/length.html) of `x`

## See also

Other Rolling Statistic:
[`rolling_beta()`](https://serkor1.github.io/ta-lib-R/reference/rolling_beta.md),
[`rolling_correlation()`](https://serkor1.github.io/ta-lib-R/reference/rolling_correlation.md),
[`rolling_max()`](https://serkor1.github.io/ta-lib-R/reference/rolling_max.md),
[`rolling_min()`](https://serkor1.github.io/ta-lib-R/reference/rolling_min.md),
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
output <- talib::rolling_standard_deviation(x = BTC[[1]])

## display the results
utils::tail(output)
#> [1] 3775.666 3126.418 1926.651 1686.101 1869.507 2048.963
```
