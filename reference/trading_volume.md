# Trading Volume

The `trading_volume()` is a generic S3 function that builds upon
'type-safe'-esque workflows limited to classes in in base `R`, and the
package-wide dependencies. Ie.
[class](https://rdrr.io/r/base/class.html) in,
[class](https://rdrr.io/r/base/class.html) out. Each method is a soft
wrapper of [model.frame](https://rdrr.io/r/stats/model.frame.html) and
therefore the OHLC-V series must be coercible to a
[data.frame](https://rdrr.io/r/base/data.frame.html).

`trading_volume()` also accepts a
[double](https://rdrr.io/r/base/double.html) vector in which case the
indicator is calculated 'as-is' without passing through
[model.frame](https://rdrr.io/r/stats/model.frame.html).
`trading_volume()` returns an `n` by `k`
[matrix](https://rdrr.io/r/base/matrix.html) computed in C by default.
When `k = 1`, the result is simplified to a
[double](https://rdrr.io/r/base/double.html) vector; for `k > 1`, the
full `n` by `k` [matrix](https://rdrr.io/r/base/matrix.html) is
returned.

## Usage

``` r
trading_volume(x, cols, ma, ...)
```

## Arguments

- x:

  An OHLC-V series that is coercible to
  [data.frame](https://rdrr.io/r/base/data.frame.html). Alternatively,
  `x` may also be supplied as a
  [double](https://rdrr.io/r/base/double.html) vector.

- cols:

  ([formula](https://rdrr.io/r/stats/formula.html)). An optional `1`
  variable [formula](https://rdrr.io/r/stats/formula.html) passed into
  [model.frame](https://rdrr.io/r/stats/model.frame.html). Internally
  uses `~volume` by default.

- ma:

  An optional list of moving average specifications.

- ...:

  Additional parameters passed into
  [model.frame](https://rdrr.io/r/stats/model.frame.html)

## See also

Other Volume Indicator:
[`chaikin_accumulation_distribution_line()`](https://serkor1.github.io/ta-lib-R/reference/chaikin_accumulation_distribution_line.md),
[`chaikin_accumulation_distribution_oscillator()`](https://serkor1.github.io/ta-lib-R/reference/chaikin_accumulation_distribution_oscillator.md),
[`on_balance_volume()`](https://serkor1.github.io/ta-lib-R/reference/on_balance_volume.md)

## Author

Serkan Korkmaz
