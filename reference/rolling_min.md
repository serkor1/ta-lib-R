# Rolling Min

The `rolling_min()` is a generic S3 function that builds upon
'type-safe'-esque workflows limited to classes in in base `R`, and the
package-wide dependencies. Ie.
[class](https://rdrr.io/r/base/class.html) in,
[class](https://rdrr.io/r/base/class.html) out.

## Usage

``` r
rolling_min(x, n = 10)
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
[`rolling_max()`](https://serkor1.github.io/ta-lib-R/reference/rolling_max.md),
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
output <- talib::rolling_min(x = BTC[[1]])

## display the results
utils::tail(output)
#> [1] 94776.00 94776.00 94167.78 94167.78 93564.00 92624.41
```
