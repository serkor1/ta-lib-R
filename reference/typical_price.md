# Typical Price

The `typical_price()` is a generic S3 function that builds upon
'type-safe'-esque workflows limited to classes in in base `R`, and the
package-wide dependencies. Ie.
[class](https://rdrr.io/r/base/class.html) in,
[class](https://rdrr.io/r/base/class.html) out. Each method is a soft
wrapper of [model.frame](https://rdrr.io/r/stats/model.frame.html) and
therefore the OHLC-V series must be coercible to a
[data.frame](https://rdrr.io/r/base/data.frame.html).

`typical_price()` also accepts a
[double](https://rdrr.io/r/base/double.html) vector in which case the
indicator is calculated 'as-is' without passing through
[model.frame](https://rdrr.io/r/stats/model.frame.html).
`typical_price()` returns an `n` by `k`
[matrix](https://rdrr.io/r/base/matrix.html) computed in C by default.
When `k = 1`, the result is simplified to a
[double](https://rdrr.io/r/base/double.html) vector; for `k > 1`, the
full `n` by `k` [matrix](https://rdrr.io/r/base/matrix.html) is
returned.

## Usage

``` r
typical_price(x, cols, ...)
```

## Arguments

- x:

  An OHLC-V series that is coercible to
  [data.frame](https://rdrr.io/r/base/data.frame.html).

- cols:

  ([formula](https://rdrr.io/r/stats/formula.html)). An optional `3`
  variable [formula](https://rdrr.io/r/stats/formula.html) passed into
  [model.frame](https://rdrr.io/r/stats/model.frame.html). Internally
  uses `~high + low + close` by default.

- ...:

  Additional parameters passed into
  [model.frame](https://rdrr.io/r/stats/model.frame.html)

## Value

An object of same [class](https://rdrr.io/r/base/class.html) and
[length](https://rdrr.io/r/base/length.html) of `x`:

- TYPPRICE:

  [double](https://rdrr.io/r/base/double.html)

## See also

Other Price Transform:
[`average_price()`](https://serkor1.github.io/ta-lib-R/reference/average_price.md),
[`median_price()`](https://serkor1.github.io/ta-lib-R/reference/median_price.md),
[`midpoint_price()`](https://serkor1.github.io/ta-lib-R/reference/midpoint_price.md),
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
output <- talib::typical_price(BTC)

## display the results
utils::tail(output)
#>                     TYPPRICE
#> 2024-12-26 01:00:00 96881.66
#> 2024-12-27 01:00:00 94958.77
#> 2024-12-28 01:00:00 94894.87
#> 2024-12-29 01:00:00 93855.27
#> 2024-12-30 01:00:00 92951.09
#> 2024-12-31 01:00:00 93802.27
```
