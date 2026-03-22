# Rolling Correlation

`rolling_correlation()` is a generic S3 function that preserves the
input [class](https://rdrr.io/r/base/class.html):
[double](https://rdrr.io/r/base/double.html) vector in,
[double](https://rdrr.io/r/base/double.html) vector out.

### Handling of -values

Leading `NA`s are always produced for the initial lookback period where
insufficient data is available. If the input itself contains `NA`s they
are passed through to the underlying C routine, which can cause the
**entire** output to be filled with `NA`s. Set `na.ignore = TRUE` to
strip `NA`s before calculation and re-insert them at their original
positions in the output.

## Usage

``` r
rolling_correlation(x, y, n = 10, na.ignore = FALSE)
```

## Arguments

- x, y:

  (([double](https://rdrr.io/r/base/double.html)),
  ([double](https://rdrr.io/r/base/double.html))). A pair of
  [double](https://rdrr.io/r/base/double.html) vectors of equal
  [length](https://rdrr.io/r/base/length.html).

- n:

  ([integer](https://rdrr.io/r/base/integer.html)). Lookback period
  (window size). A positive
  [integer](https://rdrr.io/r/base/integer.html) of
  [length](https://rdrr.io/r/base/length.html) 1.

- na.ignore:

  ([logical](https://rdrr.io/r/base/logical.html)). A
  [logical](https://rdrr.io/r/base/logical.html) of
  [length](https://rdrr.io/r/base/length.html) 1.
  [FALSE](https://rdrr.io/r/base/logical.html) by default. If
  [TRUE](https://rdrr.io/r/base/logical.html), `NA`s in the input are
  stripped before calculation and re-inserted at their original
  positions in the output.

## Value

A [double](https://rdrr.io/r/base/double.html) vector with the same
[length](https://rdrr.io/r/base/length.html) of `x`

## See also

Other Rolling Statistic:
[`rolling_beta()`](https://serkor1.github.io/ta-lib-R/reference/rolling_beta.md),
[`rolling_max()`](https://serkor1.github.io/ta-lib-R/reference/rolling_max.md),
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

## calculate the rolling statistic
## between Open and Close
output <- talib::rolling_correlation(x = BTC[[1]], y = BTC[[4]])

## display the results
utils::tail(output)
#> [1] 0.7369425 0.5788049 0.3598043 0.4020494 0.5134674 0.5397380
```
