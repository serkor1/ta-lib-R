# Rolling Min

`rolling_min()` is a generic S3 function that preserves the input
[class](https://rdrr.io/r/base/class.html):
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
rolling_min(x, n = 10, na.ignore = FALSE)
```

## Arguments

- x:

  ([double](https://rdrr.io/r/base/double.html)). A
  [double](https://rdrr.io/r/base/double.html) vector.

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
