# Average Price

The `average_price()` is a generic S3 function that builds upon
'type-safe'-esque workflows limited to classes in in base `R`, and the
package-wide dependencies. Ie.
[class](https://rdrr.io/r/base/class.html) in,
[class](https://rdrr.io/r/base/class.html) out. Each method is a soft
wrapper of [model.frame](https://rdrr.io/r/stats/model.frame.html) and
therefore the OHLC-V series must be coercible to a
[data.frame](https://rdrr.io/r/base/data.frame.html).

### Handling of -values

`average_price()` iterates over valid values, and returns `NA` for the
remaing part of series.

## Usage

``` r
average_price(x, cols, ...)
```

## Arguments

- x:

  An OHLC-V series that is coercible to
  [data.frame](https://rdrr.io/r/base/data.frame.html).

- cols:

  ([formula](https://rdrr.io/r/stats/formula.html)). An optional `4`
  variable [formula](https://rdrr.io/r/stats/formula.html) passed into
  [model.frame](https://rdrr.io/r/stats/model.frame.html). Internally
  uses `~open + high + low + close` by default.

- ...:

  Additional parameters passed into
  [model.frame](https://rdrr.io/r/stats/model.frame.html)

## Value

An object of same [class](https://rdrr.io/r/base/class.html) and
[length](https://rdrr.io/r/base/length.html) of `x`:

- AVGPRICE:

  [double](https://rdrr.io/r/base/double.html)

## See also

Other Price Transform:
[`median_price()`](https://serkor1.github.io/ta-lib-R/reference/median_price.md),
[`midpoint_price()`](https://serkor1.github.io/ta-lib-R/reference/midpoint_price.md),
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
output <- talib::average_price(BTC)

## display the results
utils::tail(output)
#>                     AVGPRICE
#> 2024-12-26 01:00:00 97500.24
#> 2024-12-27 01:00:00 95138.08
#> 2024-12-28 01:00:00 94713.10
#> 2024-12-29 01:00:00 94172.46
#> 2024-12-30 01:00:00 93104.32
#> 2024-12-31 01:00:00 93507.80
```
