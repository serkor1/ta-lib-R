# version 0.9-3

## improvements

* A new function for pre-calculating the lookback-period has been implemented. It can be used as follows:

```R
talib::lookback(
  FUN = talib::SMA,
  n   = 10,
  x   = talib::BTC
)
```

The function returns the minimum required lookback for calculating the indicator.
Its use-case is customized control-flows for downstream wrappers and/or packages that declares dependency on {talib}.

## bug-fixes

# version 0.9-2

## improvements

* The `configure` for UNIX have been improved and follows 'Writing R Extensions' more closely so its more robust across different operating systems. 

* The `configure` now probes for user-installed libraries uses `pkgconf` and *should* locate libraries and headers installed in non-default PATHs.

# version 0.9-1

## improvements

* The `MAMA`-function now has two arguments: `fast` and `slow`, which controls 
  controls the upper and lower limit of the adaptive smoothing factor (alpha) used
  in the MESA algorithm

* The `T3`-function now has the argument `vfactor` controls the smoothing weight of the T3-curve.

## bug-fixes

* The `stochastic_relative_strength_index`-function were recursively calculating the indicator.

# version 0.9-0

* Initial CRAN submission.
* Wraps the TA-Lib C library, providing 67 technical indicators and
  61 candlestick pattern detectors.
* Composable charting via `chart()` and `indicator()`, with both
  `plotly` (interactive) and `ggplot2` (static) backends.
* Built-in OHLCV datasets: `BTC`, `ATOM`, `NVDA`, `SPY`.
