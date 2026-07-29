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

* The source code have been re-written so it generates the underlying TA-Lib wrappers using preprocessors and X-Macros, which compiles much faster than before. 

* _**MAVP:** Moving Average Variable Periods_—The function calculates a moving average with variable periods between candles. See below:

```R
talib::variable_moving_average_period(
  x = 1:10,
  periods = c(1, 1, 1, 2, 2, 2, 3, 4, 4, 4),
  minimumPeriod = 2,
  maximumPeriod = 4
)

#> [1]  NA  NA  NA 3.5 4.5 5.5 6.0 6.5 7.5 8.5
#> attr(,"lookback")
```

* _**AVGDEV:** Averge deviation_—The function calculates the average deviation of a series. See below:

```R
talib::average_deviation(
x = 1:10,
periods = c(1, 1, 1, 2, 2, 2, 3, 4, 4, 4),
timePeriod = 5
)
#>  [1]  NA  NA  NA  NA 1.2 1.2 1.2 1.2 1.2 1.2
#> attr(,"lookback")
#> [1] 4
```

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

* _**CCI:** Incorrect charting_—The indicator were incorrectly classified as a main chart indicator— 

* _**One-dimensional indicators:** incorrect return \<class\>_—Indicators that returns a one-dimensional indicator (MA, RSI, etc.) were returning a \<matrix\> or \<data.frame\> instead of \<numeric\>.

* _**Merged indicators:** overlapping last-values_—On the plotly backend, merging indicators onto one panel stacked every last-value label on the panel's top-right corner. The labels are now collapsed into a single evenly spaced label, mirroring the merged subtitle of the ggplot2 backend.

* _**Merged indicators:** indistinguishable last-values_—Merged last-value labels used the bare output column name, so merging the same indicator with different parameters displayed identical labels. The labels now carry the full indicator specification, including its parameters, as the ggplot2 backend already did.

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
