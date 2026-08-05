# Changelog

## version 0.9-3

This version brings *many* changes to the R package. The entire code
generating backend have been rewritten so it *closely* follows the
upstream naming of parameters and it uses X-macros so it also installs
way fastert than before - but it also means that there is alot of
breaking changes. The update is a big leap towards a stable release.

### improvements

- A new function for pre-calculating the lookback-period has been
  implemented. It can be used as follows:

``` r

talib::lookback(
  FUN = talib::SMA,
  n   = 10,
  x   = talib::BTC
)
```

The function returns the minimum required lookback for calculating the
indicator. Its use-case is customized control-flows for downstream
wrappers and/or packages that declares dependency on {talib}.

- The source code have been re-written so it generates the underlying
  TA-Lib wrappers using preprocessors and X-Macros, which compiles much
  faster than before.

- ***\<xts\>**-methods:*—All indicators now supports \<xts\>-objects.
  These methods are considered the primary entry point for *all*
  indicators, and can be considered stable from v1.0.0, where changes—if
  any—will be implemented gradually after a deprecation period. The
  method uses the same signature as before, see the example below:

``` r

library(xts)

tail(
  x <- talib::bollinger_bands(
    talib::GOOGL
  )
)
#>            UpperBand MiddleBand LowerBand
#> 2021-12-22  149.1432   144.4920  139.8408
#> 2021-12-23  149.2513   144.5318  139.8124
#> 2021-12-27  149.6263   144.8180  140.0097
#> 2021-12-28  149.7444   144.8758  140.0072
#> 2021-12-29  149.8398   145.1137  140.3876
#> 2021-12-30  149.7308   145.3711  141.0115

class(x)
#> [1] "xts" "zoo"
```

- ***MAVP:** Moving Average Variable Periods*—The function calculates a
  moving average with variable periods between candles. See below:

``` r

talib::variable_moving_average_period(
  x = 1:10,
  periods = c(1, 1, 1, 2, 2, 2, 3, 4, 4, 4),
  minimumPeriod = 2,
  maximumPeriod = 4
)

#> [1]  NA  NA  NA 3.5 4.5 5.5 6.0 6.5 7.5 8.5
#> attr(,"lookback")
```

- ***AVGDEV:** Averge deviation*—The function calculates the average
  deviation of a series. See below:

``` r

talib::average_deviation(
x = 1:10,
periods = c(1, 1, 1, 2, 2, 2, 3, 4, 4, 4),
timePeriod = 5
)
#>  [1]  NA  NA  NA  NA 1.2 1.2 1.2 1.2 1.2 1.2
#> attr(,"lookback")
#> [1] 4
```

- All indicators have gotten a `camelCase` alias to introduce a form of
  consistency across R’s finance ecosystem and oldschool coding schemes.
  The indicators below produces the same output:

``` r

talib::bollinger_bands()
talib::BBANDS()
talib::bollingerBands()
```

Each `UPPERCASE` and `camelCase` function is an alias of its underlying
`snake_case` function, so the functions behaves the same.

### breaking changes

- **General:** All functions now follows the naming convention of
  TA-Lib. All function signatures are on the following form:

``` r

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

This has the benefit of being transparent when comparing or reading the
source code.

- **MATypes:** Functions that used MATypes in the indicator function are
  now significantly different. See the
  [`bollinger_bands()`](https://serkor1.github.io/ta-lib-R/reference/bollinger_bands.md)
  below:

``` r

talib::bollinger_bands(
        talib::BTC,
        timePeriod = 20,
        maType = talib::EMA()
)
```

Prior to this update, the correct call was:

``` r

talib::bollinger_bands(
        talib::BTC,
    ma = talib::EMA(n = 20)
)
```

While the above function call is aestethically pleasing, it did
introduce some ambigiuites in other calls. See, for example,
[`APO()`](https://serkor1.github.io/ta-lib-R/reference/absolute_price_oscillator.md)
(v0.9.2) below:

``` r

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

In this specific case the function has three different `n` - the
underlying function were discarding `n = 9` while keeping the MAType.
The new call is given as:

``` r

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

In this call the role of each argument is *should* be clearer than
before.

- ***Moving Average (MA) signatures:***—the generic S3 signature of the
  MAs has been changed in response to the new TA-Lib (upstream) release.
  The release introduced the volume weighted moving average which uses
  the volume in its calculation. This deviates from the generic `x` +
  `timePeriod` signature, and breaks the `numeric`-method. One solution
  is to do the following:

``` r

VWMA.numeric(x, cols, timePeriod, na.bridge = FALSE, volume, ...)
```

To avoid breaking the S3 signature. However, given the importance of the
`volume`-argument and the fact that `cols` is rarely used, the signature
has been changed to accommodate future additions of MAs which take
additional series. The new signature is as follows:

``` r
foo(x, [series], timePeriod, [optional], cols, na.bridge = FALSE, ...)
```

Additional *series* (the volume) lead directly after `x`, while
additional *optional parameters* keep their place after `timePeriod`. In
the case of VWMA this becomes:

``` r

VWMA(
    x,
    volume,
    timePeriod = 30,
    cols,
    na.bridge = FALSE,
    ...
)
```

And for the remaining MAs:

``` r

foo(
    x,
    timePeriod = 30,
    cols,
    na.bridge = FALSE,
    ...
)
```

MAs with additional optional parameters retain them after `timePeriod`,
e.g. `MAMA(x, timePeriod, fastLimit, slowLimit, cols, na.bridge, ...)`
and `T3(x, timePeriod, volumeFactor, cols, na.bridge, ...)`.

The `volume`-argument is *not* required when `x` carries a volume
column: `VWMA(x)` selects it via the default formula `~close + volume`
as before. An explicitly passed vector takes precedence, in which case
only the `close`-column is required:

``` r

## volume from the 'volume'-column of x
VWMA(x)

## explicitly passed volume; only 'close' required
VWMA(x, volume = my_volume)

## fully positional on vectors
VWMA(price, volume, 20)
```

**NOTE:** passing `cols` *positionally* as the second argument no longer
works for the MAs—it has to be passed by name, ie.
`SMA(x, cols = ~open)`.

### bug-fixes

- ***CCI:** Incorrect charting*—The indicator were incorrectly
  classified as a main chart indicator—

- ***One-dimensional indicators:** incorrect return
  \<class\>*—Indicators that returns a one-dimensional indicator (MA,
  RSI, etc.) were returning a \<matrix\> or \<data.frame\> instead of
  \<numeric\>.

- ***Merged indicators:** overlapping last-values*—On the plotly
  backend, merging indicators onto one panel stacked every last-value
  label on the panel’s top-right corner. The labels are now collapsed
  into a single evenly spaced label, mirroring the merged subtitle of
  the ggplot2 backend.

- ***Merged indicators:** indistinguishable last-values*—Merged
  last-value labels used the bare output column name, so merging the
  same indicator with different parameters displayed identical labels.
  The labels now carry the full indicator specification, including its
  parameters, as the ggplot2 backend already did.

## version 0.9-2

CRAN release: 2026-05-10

### improvements

- The `configure` for UNIX have been improved and follows ‘Writing R
  Extensions’ more closely so its more robust across different operating
  systems.

- The `configure` now probes for user-installed libraries uses `pkgconf`
  and *should* locate libraries and headers installed in non-default
  PATHs.

## version 0.9-1

CRAN release: 2026-04-23

### improvements

- The `MAMA`-function now has two arguments: `fast` and `slow`, which
  controls controls the upper and lower limit of the adaptive smoothing
  factor (alpha) used in the MESA algorithm

- The `T3`-function now has the argument `vfactor` controls the
  smoothing weight of the T3-curve.

### bug-fixes

- The `stochastic_relative_strength_index`-function were recursively
  calculating the indicator.

## version 0.9-0

CRAN release: 2026-04-21

- Initial CRAN submission.
- Wraps the TA-Lib C library, providing 67 technical indicators and 61
  candlestick pattern detectors.
- Composable charting via
  [`chart()`](https://serkor1.github.io/ta-lib-R/reference/chart.md) and
  [`indicator()`](https://serkor1.github.io/ta-lib-R/reference/indicator.md),
  with both `plotly` (interactive) and `ggplot2` (static) backends.
- Built-in OHLCV datasets: `BTC`, `ATOM`, `NVDA`, `SPY`.
