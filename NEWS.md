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
