# Changelog

## talib 0.9-0

- Initial CRAN submission.
- Wraps the TA-Lib C library, providing 67 technical indicators and 61
  candlestick pattern detectors.
- Composable charting via
  [`chart()`](https://serkor1.github.io/ta-lib-R/reference/chart.md) and
  [`indicator()`](https://serkor1.github.io/ta-lib-R/reference/indicator.md),
  with both `plotly` (interactive) and `ggplot2` (static) backends.
- Built-in OHLCV datasets: `BTC`, `ATOM`, `NVDA`, `SPY`.
