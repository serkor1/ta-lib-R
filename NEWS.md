# version 0.9-3

This version brings *many* changes to the R package.
The entire code generating backend have been rewritten so it *closely* follows the upstream naming of parameters and it uses X-macros so it also installs way fastert than before - but it also means that there is alot of breaking changes.
The update is a big leap towards a stable release.

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

* The underlying source code have been completely rewritten so {talib} compiles much faster than before.


* ***MAVP:** Moving Average Variable Periods*—The function calculates a moving average with variable periods between candles. See below:

```R
## generate series
x <- data.frame(
  close = 1:10,
  periods = c(1, 1, 1, 2, 2, 2, 3, 4, 4, 4)
)

talib::variable_moving_average_period(
  x = x,
  minimumPeriod = 2,
  maximumPeriod = 4
)

#>    MAVP
#> 1    NA
#> 2    NA
#> 3    NA
#> 4   3.5
#> 5   4.5
#> 6   5.5
#> 7   6.0
#> 8   6.5
#> 9   7.5
#> 10  8.5
```




* AVGDEV


## breaking changes

* **General:** All functions now follows the naming convention of TA-Lib. All function signatures are on the following form:

```R
indicator(
  x,          ## unchanged
  cols,       ## unchanged
  ## additional/optional TA-Lib parameters
  ## are now camelCase mined upstream
  timePeriod, ## was 'n' before
  fooBar,     ## was 'foo_bar' or 'foobar' before
  fooBaz,     ## was 'foo_baz' or 'foobaz' before
  na.bridge = FALSE ## unchanged
)
```

This has the benefit of being transparent when comparing or reading the source code.

* **MATypes:** Functions that used MATypes in the indicator function are now significantly different. See the `bollinger_bands()` below:

```R
talib::bollinger_bands(
		talib::BTC,
		timePeriod = 20,
		maType = talib::EMA()
)
```

Prior to this update, the correct call was:

```R
talib::bollinger_bands(
		talib::BTC,
    ma = talib::EMA(n = 20)
)
```

While the above function call is aestethically pleasing, it did introduce some ambigiuites in other calls. See, for example, `APO()` (v0.9.2) below:

```R
absolute_price_oscillator(
  x,
  cols,
  fast = 12,
  slow = 26,
  ma = SMA(n = 9),
  na.bridge = FALSE,
  ...
)
```

In this specific case the function has three different `n` - the underlying function were discarding `n = 9` while keeping the MAType.
The new call is given as:

```R
absolute_price_oscillator(
	x,
	cols,
	fastPeriod = 12,
	slowPeriod = 26,
	maType = 0,
	na.bridge = FALSE,
	...
) 
```

In this call the role of each argument is *should* be clearer than before.



## bug-fixes

* CCI as main chart should have been subchart
* Correct return of one-dimensional indicators


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
