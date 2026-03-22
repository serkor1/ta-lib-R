# Midpoint Price

`midpoint_price()` is a generic S3 function that preserves the input
[class](https://rdrr.io/r/base/class.html):
[data.frame](https://rdrr.io/r/base/data.frame.html) in,
[data.frame](https://rdrr.io/r/base/data.frame.html) out;
[matrix](https://rdrr.io/r/base/matrix.html) in,
[matrix](https://rdrr.io/r/base/matrix.html) out.

### Handling of -values

Leading `NA`s are always produced for the initial lookback period where
insufficient data is available. If the input itself contains `NA`s they
are passed through to the underlying C routine, which can cause the
**entire** output to be filled with `NA`s. Set `na.ignore = TRUE` to
strip `NA`s before calculation and re-insert them at their original
positions in the output.

## Usage

``` r
midpoint_price(x, cols, n = 10, na.ignore = FALSE, ...)
```

## Arguments

- x:

  An OHLC-V series coercible to
  [data.frame](https://rdrr.io/r/base/data.frame.html).

- cols:

  ([formula](https://rdrr.io/r/stats/formula.html)). An optional
  `2`-variable [formula](https://rdrr.io/r/stats/formula.html) selecting
  columns from `x` via
  [model.frame](https://rdrr.io/r/stats/model.frame.html). Defaults to
  `~high + low`.

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

- ...:

  Additional parameters passed into
  [model.frame](https://rdrr.io/r/stats/model.frame.html)

## Value

An object of same [class](https://rdrr.io/r/base/class.html) and
[length](https://rdrr.io/r/base/length.html) of `x`:

- MIDPRICE:

  [double](https://rdrr.io/r/base/double.html)

## See also

Other Price Transform:
[`average_price()`](https://serkor1.github.io/ta-lib-R/reference/average_price.md),
[`median_price()`](https://serkor1.github.io/ta-lib-R/reference/median_price.md),
[`typical_price()`](https://serkor1.github.io/ta-lib-R/reference/typical_price.md),
[`weighted_close_price()`](https://serkor1.github.io/ta-lib-R/reference/weighted_close_price.md)

## Author

Serkan Korkmaz

## Examples

``` r
## load Bitcoin (BTC)
## series
data(BTC, package = "talib")

## calculate the indicator
## for Bitcoin (BTC)
output <- talib::midpoint_price(BTC)

## display the results
utils::tail(output)
#>                      MIDPRICE
#> 2024-12-26 01:00:00 100246.05
#> 2024-12-27 01:00:00  99324.18
#> 2024-12-28 01:00:00  97441.49
#> 2024-12-29 01:00:00  96004.49
#> 2024-12-30 01:00:00  95594.99
#> 2024-12-31 01:00:00  95594.99
```
