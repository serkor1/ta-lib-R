# Variance

`rolling_variance()` is a generic S3 function that preserves the input
[class](https://rdrr.io/r/base/class.html):
[double](https://rdrr.io/r/base/double.html) vector in,
[double](https://rdrr.io/r/base/double.html) vector out.

### Handling of `NA` values

Leading `NA`s are always produced for the initial lookback period where
insufficient data is available. If the input itself contains `NA`s, the
behaviour depends on `na.bridge`:

- `na.bridge = FALSE` (default):

  `NA`s propagate through the TA-Lib C routine. Because rolling
  statistics smooth across time, a single `NA` in the input typically
  poisons every subsequent value.

- `na.bridge = TRUE`:

  Input `NA`s are stripped, the statistic is computed on the dense
  series, and `NA`s are re-inserted at the original positions. Output
  length matches input length, but the computation treats
  non-consecutive observations as if they were adjacent - fine for
  sparse missing values, misleading across clustered gaps.

## Usage

``` r
rolling_variance(x, timePeriod = 5, deviations = 1, na.bridge = FALSE, ...)
```

## Arguments

- x:

  ([double](https://rdrr.io/r/base/double.html)). A
  [double](https://rdrr.io/r/base/double.html) vector.

- timePeriod:

  ([integer](https://rdrr.io/r/base/integer.html)). Lookback period
  (window size). A positive
  [integer](https://rdrr.io/r/base/integer.html) of
  [length](https://rdrr.io/r/base/length.html) 1.

- deviations:

  ([double](https://rdrr.io/r/base/double.html)). Number of deviations.
  Defaults to `1`.

- na.bridge:

  ([logical](https://rdrr.io/r/base/logical.html)). A
  [logical](https://rdrr.io/r/base/logical.html) of
  [length](https://rdrr.io/r/base/length.html) 1.
  [FALSE](https://rdrr.io/r/base/logical.html) by default. When
  [FALSE](https://rdrr.io/r/base/logical.html), input `NA`s propagate
  through the TA-Lib C routine (the rolling computation typically fills
  the remaining output with `NA`). When
  [TRUE](https://rdrr.io/r/base/logical.html), input `NA` rows are
  stripped before computation and re-inserted at the original positions
  in the output, causing the statistic to treat non-consecutive non-`NA`
  observations as if they were adjacent - see the **Handling of `NA`
  values** section above for the consequences.

- ...:

  Additional parameters.

## Value

A [double](https://rdrr.io/r/base/double.html) vector with the same
[length](https://rdrr.io/r/base/length.html) of `x`

## See also

Other Rolling Statistics:
[`rolling_beta()`](https://serkor1.github.io/ta-lib-R/reference/rolling_beta.md),
[`rolling_correlation()`](https://serkor1.github.io/ta-lib-R/reference/rolling_correlation.md),
[`rolling_maximum()`](https://serkor1.github.io/ta-lib-R/reference/rolling_maximum.md),
[`rolling_minimum()`](https://serkor1.github.io/ta-lib-R/reference/rolling_minimum.md),
[`rolling_standard_deviation()`](https://serkor1.github.io/ta-lib-R/reference/rolling_standard_deviation.md),
[`rolling_sum()`](https://serkor1.github.io/ta-lib-R/reference/rolling_sum.md)

## Author

Serkan Korkmaz

## Examples

``` r
## load Bitcoin (BTC)
## series
data(BTC, package = "talib")

## calculate the indicator
## Open
output <- talib::rolling_variance(x = BTC[[1]])

## display the results
utils::tail(output)
#> [1] 3341785 3588907 4321770 4099366 4106782 1183102
```
