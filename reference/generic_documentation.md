# Generic function documentation

A generic documentation block for documenting parameters that are common
across all functions. Avoids documenting parameters that doesn't exist
downstream.

## Arguments

- x:

  An OHLC-V series that is coercible to
  [data.frame](https://rdrr.io/r/base/data.frame.html). The function
  assumes that all columns are named in lowercase and order invariant.

- cols:

  ([formula](https://rdrr.io/r/stats/formula.html)). An optional
  [formula](https://rdrr.io/r/stats/formula.html) passed into
  [model.frame](https://rdrr.io/r/stats/model.frame.html). If passed
  into indicators based on univariate series, the function calculates
  indicators for each element in 'cols'. For indicators based on
  multivariate series, it will alter the calculation itself. See
  [`vignette("talib")`](https://serkor1.github.io/ta-lib-R/articles/talib.md)
  for more details.

- n:

  ([integer](https://rdrr.io/r/base/integer.html)). An
  [integer](https://rdrr.io/r/base/integer.html) of
  [length](https://rdrr.io/r/base/length.html) 1.

- eps:

  ([double](https://rdrr.io/r/base/double.html)). A
  [double](https://rdrr.io/r/base/double.html) of
  [length](https://rdrr.io/r/base/length.html) 1. Percentage of
  penetration of a candle within another candle.

- na.ignore:

  ([logical](https://rdrr.io/r/base/logical.html)). A
  [logical](https://rdrr.io/r/base/logical.html) of
  [length](https://rdrr.io/r/base/length.html) 1.
  [FALSE](https://rdrr.io/r/base/logical.html) by default. If
  [TRUE](https://rdrr.io/r/base/logical.html) 's are ignored during
  calculation to avoid returning `x` filled with 's.

- ...:

  Additional parameters passed into
  [model.frame](https://rdrr.io/r/stats/model.frame.html)
