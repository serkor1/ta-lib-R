# Generic function documentation

A generic documentation block for documenting parameters that are common
across all functions. Avoids documenting parameters that doesn't exist
downstream.

## Arguments

- x:

  An OHLC-V series coercible to
  [data.frame](https://rdrr.io/r/base/data.frame.html). Columns must be
  named in lowercase (`open`, `high`, `low`, `close`, `volume`); column
  order does not matter.

- cols:

  ([formula](https://rdrr.io/r/stats/formula.html)). An optional
  [formula](https://rdrr.io/r/stats/formula.html) selecting columns from
  `x` via [model.frame](https://rdrr.io/r/stats/model.frame.html) (e.g.,
  `cols = ~close` or `cols = ~high + low`). For indicators based on a
  single column (e.g., Bollinger Bands, moving averages) each variable
  in `cols` is calculated independently; for indicators based on
  multiple columns (e.g., Stochastic) the selected columns replace the
  defaults used in the calculation. See
  [`vignette("talib")`](https://serkor1.github.io/ta-lib-R/articles/talib.md)
  for details.

- n:

  ([integer](https://rdrr.io/r/base/integer.html)). Lookback period
  (window size). A positive
  [integer](https://rdrr.io/r/base/integer.html) of
  [length](https://rdrr.io/r/base/length.html) 1.

- eps:

  ([double](https://rdrr.io/r/base/double.html)). Penetration threshold
  for candlestick pattern recognition, expressed as a fraction of the
  candle body. A [double](https://rdrr.io/r/base/double.html) of
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
