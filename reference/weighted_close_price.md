# Weighted Close Price

The `weighted_close_price()` is a generic S3 function that builds upon
'type-safe'-esque workflows limited to classes in in base `R`, and the
package-wide dependencies. Ie.
[class](https://rdrr.io/r/base/class.html) in,
[class](https://rdrr.io/r/base/class.html) out. Each method is a soft
wrapper of [model.frame](https://rdrr.io/r/stats/model.frame.html) and
therefore the OHLC-V series must be coercible to a
[data.frame](https://rdrr.io/r/base/data.frame.html).

### Handling of -values

`weighted_close_price()` iterates over valid values, and returns `NA`
for the remaing part of series.

## Usage

``` r
weighted_close_price(x, cols, ...)
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

- WCLPRICE:

  [double](https://rdrr.io/r/base/double.html)

## See also

Other Price Transform:
[`average_price()`](https://serkor1.github.io/ta-lib-R/reference/average_price.md),
[`median_price()`](https://serkor1.github.io/ta-lib-R/reference/median_price.md),
[`midpoint_price()`](https://serkor1.github.io/ta-lib-R/reference/midpoint_price.md),
[`typical_price()`](https://serkor1.github.io/ta-lib-R/reference/typical_price.md)

## Author

Serkan Korkmaz

## Examples

``` r
## load Bitcoin (BTC)
## series
data(BTC, package = "talib")

## calculate the indicator
## for Bitcoin (BTC)
output <- talib::weighted_close_price(BTC)

## display the results
utils::tail(output)
#>                     WCLPRICE
#> 2024-12-26 01:00:00 96580.25
#> 2024-12-27 01:00:00 94761.02
#> 2024-12-28 01:00:00 94951.35
#> 2024-12-29 01:00:00 93782.45
#> 2024-12-30 01:00:00 92870.32
#> 2024-12-31 01:00:00 93699.36
```
