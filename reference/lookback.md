# Calculate lookback period

The function calculates the lookback period for a given indicator. Its
primarily meant as a helper function for downstream packages that wants
to use a customized control-flow.

## Usage

``` r
lookback(FUN, ...)
```

## Arguments

- FUN:

  A [call](https://rdrr.io/r/base/call.html) or
  [function](https://rdrr.io/r/base/function.html).

- ...:

  Additional parameters passed into the indicator function. See examples
  for more details.

## Value

The minimum lookback required to calculate the indicator. If the
indicator specification and input data are invalid the function returns
[NA](https://rdrr.io/r/base/NA.html), otherwise it returns an
[integer](https://rdrr.io/r/base/integer.html) of
[length](https://rdrr.io/r/base/length.html) 1.

## Author

Serkan Korkmaz

## Examples

``` r
## calculate the lookback
## for the bollinger bands
talib::lookback(
  talib::bollinger_bands,
 x = talib::BTC
)
#> [1] 4
```
