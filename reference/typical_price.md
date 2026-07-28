# Typical Price

`typical_price()` is a generic S3 function that preserves the input
[class](https://rdrr.io/r/base/class.html):
[data.frame](https://rdrr.io/r/base/data.frame.html) in,
[data.frame](https://rdrr.io/r/base/data.frame.html) out;
[matrix](https://rdrr.io/r/base/matrix.html) in,
[matrix](https://rdrr.io/r/base/matrix.html) out.

### Handling of `NA` values

Every indicator always emits **leading `NA`s** for the initial lookback
period - positions where there is not yet enough data to produce a
result. This is separate from how `NA`s already present in the input are
handled, which is controlled by the `na.bridge` argument:

- `na.bridge = FALSE` (default):

  The input is passed to the underlying TA-Lib C routine as-is. Because
  most indicators smooth across time (EMA, RSI, MACD, Bollinger Bands,
  ...), a single `NA` in the input typically propagates forward and
  **poisons every subsequent value** - it is common for one missing
  observation to produce an output that is entirely `NA` from that
  position onward. This mode is the right choice when you want to *see*
  the missing data in the output rather than silently compute around it.

- `na.bridge = TRUE`:

  `NA` rows are stripped from the input before the C routine runs; the
  indicator is computed on the resulting dense series; results are then
  re-expanded to the original length with `NA` inserted at every
  position the input had `NA`. Output length always matches input
  length, so the result can be joined back to the source `data.frame` by
  row.

  **Consequence to understand before enabling:** bridging causes the
  indicator to treat non-consecutive observations as consecutive. A
  14-period RSI with `na.bridge = TRUE` over a series containing a
  month-long gap will compute using 14 observations that span several
  real-world months as if they were 14 adjacent trading days. For sparse
  missing values (e.g. a single missing tick) this is harmless; for
  clustered gaps (e.g. a delisted period, a weekend encoded as `NA`) the
  output is correctly aligned *by position* but economically meaningless
  across the gap. Inspect gap structure with `which(is.na(x))` before
  enabling on low-quality time series.

## Usage

``` r
typical_price(x, cols, na.bridge = FALSE, ...)
```

## Arguments

- x:

  An OHLC-V series coercible to
  [data.frame](https://rdrr.io/r/base/data.frame.html).

- cols:

  ([formula](https://rdrr.io/r/stats/formula.html)). An optional
  `3`-variable [formula](https://rdrr.io/r/stats/formula.html) selecting
  columns from `x` via
  [model.frame](https://rdrr.io/r/stats/model.frame.html). Defaults to
  `~high + low + close`.

- na.bridge:

  ([logical](https://rdrr.io/r/base/logical.html)). A
  [logical](https://rdrr.io/r/base/logical.html) of
  [length](https://rdrr.io/r/base/length.html) 1.
  [FALSE](https://rdrr.io/r/base/logical.html) by default. When
  [FALSE](https://rdrr.io/r/base/logical.html), input `NA`s propagate
  through the TA-Lib C routine (most indicators will fill the remaining
  output with `NA`). When [TRUE](https://rdrr.io/r/base/logical.html),
  input `NA` rows are stripped before computation and re-inserted at the
  original positions in the output, causing the indicator to treat
  non-consecutive non-`NA` observations as if they were adjacent — see
  the **Handling of `NA` values** section above for the consequences.

- ...:

  Additional parameters passed into
  [model.frame](https://rdrr.io/r/stats/model.frame.html).

## Value

An object of same [class](https://rdrr.io/r/base/class.html) and
[length](https://rdrr.io/r/base/length.html) of `x`:

- TYPPRICE:

  [double](https://rdrr.io/r/base/double.html)

## See also

Other Price Transform:
[`average_deviation()`](https://serkor1.github.io/ta-lib-R/reference/average_deviation.md),
[`average_price()`](https://serkor1.github.io/ta-lib-R/reference/average_price.md),
[`median_price()`](https://serkor1.github.io/ta-lib-R/reference/median_price.md),
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
