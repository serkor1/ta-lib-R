# Midpoint Price

The `midpoint_price()` is a generic S3 function that builds upon
'type-safe'-esque workflows limited to classes in in base `R`, and the
package-wide dependencies. Ie.
[class](https://rdrr.io/r/base/class.html) in,
[class](https://rdrr.io/r/base/class.html) out. Each method is a soft
wrapper of [model.frame](https://rdrr.io/r/stats/model.frame.html) and
therefore the OHLC-V series must be coercible to a
[data.frame](https://rdrr.io/r/base/data.frame.html). This rule does not
transfer to indicators that uses univariate series, unless passed as a
1-column [data.frame](https://rdrr.io/r/base/data.frame.html) or
[matrix](https://rdrr.io/r/base/matrix.html). In such cases, if
univariate series is passed as a
[vector](https://rdrr.io/r/base/vector.html) the function calculates the
indicator 'as is', and returns a
[data.frame](https://rdrr.io/r/base/data.frame.html) if the indicator
itself is also a univariate series.

The indicator, by default, follows its mathematical definition. However,
the `cols` argument allows for simple rearrangement of the definition by
passing relevant columns in a custom order. Refer to the details-section
for more on the calculation of the indicators.

## Usage

``` r
midpoint_price(x, cols, n = 10, ...)
```

## Arguments

- x:

  An OHLC-V series that is coercible to
  [data.frame](https://rdrr.io/r/base/data.frame.html). The function
  assumes that all columns are named in lowercase and order invariant.

- cols:

  An optional [formula](https://rdrr.io/r/stats/formula.html) passed
  into [model.frame](https://rdrr.io/r/stats/model.frame.html). If
  passed into indicators based on univariate series, the function
  calculates indicators for each element in 'cols'. For indicators based
  on multivariate series, it will alter the calculation itself. See
  [`vignette("talib")`](https://serkor1.github.io/ta-lib-R/articles/talib.md)
  for more details.

- n:

  An [integer](https://rdrr.io/r/base/integer.html) of
  [length](https://rdrr.io/r/base/length.html) 1.

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

## visualize the indicator
## with candlesticks
##
## see ?talib::chart or ?talib::indicator
## for more details
{
 ## chart OHLC-V
 ## series with candlesticks
 talib::chart(BTC)

 ## chart indicator
 ## with default values
 talib::indicator(
     talib::midpoint_price
 )
}
#> Error in as.data.frame.default(data): cannot coerce class ‘c("plotly", "htmlwidget")’ to a data.frame
```
