# Candlestick Pattern Recognition

[{talib}](https://github.com/serkor1/ta-lib-R/) includes 61 candlestick
pattern recognition functions ported from
[TA-Lib](https://github.com/TA-Lib/ta-lib). This vignette covers how
they work, what they return, and how to tune their sensitivity.

## A primer on candlesticks

A candlestick shows four prices for a chosen time period: Open, High,
Low, and Close (OHLC).

The **real body** is the segment between the Open and the Close. If the
Close is above the Open the candle is bullish; otherwise it is bearish.

The **upper shadow** extends from the top of the real body to the High;
the **lower shadow** extends from the bottom of the real body to the
Low. Together the shadows show how far price moved beyond the Open-Close
range.

Candlestick patterns are defined by comparing the size and position of
bodies and shadows—within a single candle or across a sequence of
consecutive candles.

## Available patterns

The 61 pattern functions can be loosely grouped by how many candles they
inspect:

| Candles       | Examples                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
|:--------------|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Single-candle | [`doji()`](https://serkor1.github.io/ta-lib-R/reference/doji.md), [`hammer()`](https://serkor1.github.io/ta-lib-R/reference/hammer.md), [`shooting_star()`](https://serkor1.github.io/ta-lib-R/reference/shooting_star.md), [`marubozu()`](https://serkor1.github.io/ta-lib-R/reference/marubozu.md), [`spinning_top()`](https://serkor1.github.io/ta-lib-R/reference/spinning_top.md), [`long_line()`](https://serkor1.github.io/ta-lib-R/reference/long_line.md), [`short_line()`](https://serkor1.github.io/ta-lib-R/reference/short_line.md) |
| Two-candle    | [`engulfing()`](https://serkor1.github.io/ta-lib-R/reference/engulfing.md), [`harami()`](https://serkor1.github.io/ta-lib-R/reference/harami.md), [`harami_cross()`](https://serkor1.github.io/ta-lib-R/reference/harami_cross.md), [`piercing()`](https://serkor1.github.io/ta-lib-R/reference/piercing.md), [`dark_cloud_cover()`](https://serkor1.github.io/ta-lib-R/reference/dark_cloud_cover.md), [`kicking()`](https://serkor1.github.io/ta-lib-R/reference/kicking.md)                                                                   |
| Three-candle  | [`morning_star()`](https://serkor1.github.io/ta-lib-R/reference/morning_star.md), [`evening_star()`](https://serkor1.github.io/ta-lib-R/reference/evening_star.md), [`three_inside()`](https://serkor1.github.io/ta-lib-R/reference/three_inside.md), [`three_outside()`](https://serkor1.github.io/ta-lib-R/reference/three_outside.md), [`three_white_soldiers()`](https://serkor1.github.io/ta-lib-R/reference/three_white_soldiers.md), [`three_black_crows()`](https://serkor1.github.io/ta-lib-R/reference/three_black_crows.md)           |
| Four+ candle  | [`concealing_baby_swallow()`](https://serkor1.github.io/ta-lib-R/reference/concealing_baby_swallow.md), `rising_falling_three_methods()`, [`mat_hold()`](https://serkor1.github.io/ta-lib-R/reference/mat_hold.md), [`break_away()`](https://serkor1.github.io/ta-lib-R/reference/break_away.md)                                                                                                                                                                                                                                                 |

Every function has a descriptive snake_case name and an uppercase alias
matching the TA-Lib convention (`doji` / `CDLDOJI`, `engulfing` /
`CDLENGULFING`, etc.).

## Return values

All pattern functions require OHLC columns
(`~open + high + low + close`) and return an integer matrix of the same
length as the input:

- **`1`** — bullish pattern (or direction-neutral pattern) identified
- **`-1`** — bearish pattern identified
- **`0`** — no pattern

``` r
x <- talib::doji(talib::BTC)
table(x)
#> CDLDOJI
#>   0   1 
#> 300  56
```

Some patterns are inherently directional (e.g.,
[`engulfing()`](https://serkor1.github.io/ta-lib-R/reference/engulfing.md)
returns both `1` and `-1`), while others are direction-neutral (e.g.,
[`doji()`](https://serkor1.github.io/ta-lib-R/reference/doji.md) always
returns `1` for identified patterns).

### Output encoding

By default, patterns are normalized to `1`/`-1`/`0`. The original TA-Lib
encoding (`100`/`-100`/`0`) can be restored with:

``` r
options(talib.normalize = FALSE)
table(talib::engulfing(talib::BTC))
#> CDLENGULFING
#> -100  -80    0   80  100 
#>   19   11  297   12   25
```

### The `eps` parameter

Seven patterns accept an `eps` (penetration) parameter that controls how
far one candle must intrude into the body of another. These are
[`morning_star()`](https://serkor1.github.io/ta-lib-R/reference/morning_star.md),
[`evening_star()`](https://serkor1.github.io/ta-lib-R/reference/evening_star.md),
[`morning_doji_star()`](https://serkor1.github.io/ta-lib-R/reference/morning_doji_star.md),
[`evening_doji_star()`](https://serkor1.github.io/ta-lib-R/reference/evening_doji_star.md),
[`abandoned_baby()`](https://serkor1.github.io/ta-lib-R/reference/abandoned_baby.md),
[`dark_cloud_cover()`](https://serkor1.github.io/ta-lib-R/reference/dark_cloud_cover.md),
and
[`mat_hold()`](https://serkor1.github.io/ta-lib-R/reference/mat_hold.md).
The default is `eps = 0` for all of them.

``` r
## Evening Star with 30% penetration
x <- talib::evening_star(talib::BTC, eps = 0.3)
sum(abs(x), na.rm = TRUE)
#> [1] 0
```

## Lookback and `NA` values

Every pattern has a **lookback period**: the number of initial rows that
are returned as `NA` because the algorithm needs historical context
before it can evaluate. The lookback depends on two things: the number
of candles in the pattern itself, and the `N` parameter that controls
how many prior candles are used to compute reference values for
body/shadow classification.

``` r
x <- talib::doji(talib::BTC)
attr(x, "lookback")
#> [1] 10
```

## Tuning candlestick settings

Pattern recognition in [{talib}](https://github.com/serkor1/ta-lib-R/)
relies on classifying each candle’s body and shadows as “long”, “short”,
“doji-like”, etc. These classifications are controlled by two parameters
per setting:

- **`N`** (lookback): How many prior candles to average when computing
  the reference value.
- **`alpha`** (sensitivity): A multiplier applied to the reference
  value. The current candle is tested against `alpha * reference`.

All settings are modified via
[`options()`](https://rdrr.io/r/base/options.html) and take effect on
the next pattern function call.

### Available settings

The complete list of settings, their defaults, and what they control:

**Body settings:**

| Setting      | Option prefix        |   N | alpha | Rule                                                                  |
|:-------------|:---------------------|----:|------:|:----------------------------------------------------------------------|
| BodyLong     | `talib.BodyLong`     |  10 |   1.0 | Body is long when longer than the average of the N previous bodies    |
| BodyVeryLong | `talib.BodyVeryLong` |  10 |   3.0 | Body is very long when longer than 3x the average                     |
| BodyShort    | `talib.BodyShort`    |  10 |   1.0 | Body is short when shorter than the average                           |
| BodyDoji     | `talib.BodyDoji`     |  10 |   0.1 | Body is doji-like when shorter than 10% of the average high-low range |

**Shadow settings:**

| Setting         | Option prefix           |   N | alpha | Rule                                                                     |
|:----------------|:------------------------|----:|------:|:-------------------------------------------------------------------------|
| ShadowLong      | `talib.ShadowLong`      |   0 |   1.0 | Shadow is long when longer than the real body                            |
| ShadowVeryLong  | `talib.ShadowVeryLong`  |   0 |   2.0 | Shadow is very long when longer than 2x the real body                    |
| ShadowShort     | `talib.ShadowShort`     |  10 |   1.0 | Shadow is short when shorter than half the average shadow sum            |
| ShadowVeryShort | `talib.ShadowVeryShort` |  10 |   0.1 | Shadow is very short when shorter than 10% of the average high-low range |

**Distance settings:**

| Setting | Option prefix |   N | alpha | Rule                                                          |
|:--------|:--------------|----:|------:|:--------------------------------------------------------------|
| Near    | `talib.Near`  |   5 |   0.2 | Distance is “near” when \<= 20% of the average high-low range |
| Far     | `talib.Far`   |   5 |   0.6 | Distance is “far” when \>= 60% of the average high-low range  |
| Equal   | `talib.Equal` |   5 |  0.05 | Distance is “equal” when \<= 5% of the average high-low range |

### Effect of lookback (`N`)

Changing `N` alters how many prior candles form the reference average. A
shorter lookback makes the reference more reactive to recent price
action:

``` r
## default N = 10
sum(abs(talib::doji(talib::BTC)), na.rm = TRUE)
#> [1] 56
```

``` r
## shorter lookback
options(talib.BodyDoji.N = 3)
sum(abs(talib::doji(talib::BTC)), na.rm = TRUE)
#> [1] 61
```

### Effect of sensitivity (`alpha`)

Changing `alpha` makes the classification more or less permissive. A
higher `alpha` means a wider acceptance threshold:

``` r
## default alpha = 0.1
sum(abs(talib::doji(talib::BTC)), na.rm = TRUE)
#> [1] 56
```

``` r
## more permissive: accept bodies up to 20% of the high-low range
options(talib.BodyDoji.alpha = 0.2)
sum(abs(talib::doji(talib::BTC)), na.rm = TRUE)
#> [1] 109
```

The default `alpha = 0.1` for BodyDoji means: “the real body is
doji-like when it’s shorter than 10% of the average high-low range over
the past 10 candles.” Doubling it to `0.2` loosens the criterion and
identifies more patterns.

### Which settings affect which patterns?

Different patterns depend on different settings. As a general rule:

- **Doji patterns**
  ([`doji()`](https://serkor1.github.io/ta-lib-R/reference/doji.md),
  [`doji_star()`](https://serkor1.github.io/ta-lib-R/reference/doji_star.md),
  [`dragonfly_doji()`](https://serkor1.github.io/ta-lib-R/reference/dragonfly_doji.md),
  [`gravestone_doji()`](https://serkor1.github.io/ta-lib-R/reference/gravestone_doji.md),
  [`long_legged_doji()`](https://serkor1.github.io/ta-lib-R/reference/long_legged_doji.md),
  [`rickshaw_man()`](https://serkor1.github.io/ta-lib-R/reference/rickshaw_man.md))
  are primarily controlled by `BodyDoji`.
- **Engulfing-style patterns**
  ([`engulfing()`](https://serkor1.github.io/ta-lib-R/reference/engulfing.md),
  [`harami()`](https://serkor1.github.io/ta-lib-R/reference/harami.md),
  [`dark_cloud_cover()`](https://serkor1.github.io/ta-lib-R/reference/dark_cloud_cover.md),
  [`piercing()`](https://serkor1.github.io/ta-lib-R/reference/piercing.md))
  depend on `BodyLong` and `BodyShort`.
- **Star patterns**
  ([`morning_star()`](https://serkor1.github.io/ta-lib-R/reference/morning_star.md),
  [`evening_star()`](https://serkor1.github.io/ta-lib-R/reference/evening_star.md),
  [`abandoned_baby()`](https://serkor1.github.io/ta-lib-R/reference/abandoned_baby.md))
  depend on `BodyShort`, `BodyLong`, and the shadow settings.
- **Hammer/Shooting Star**
  ([`hammer()`](https://serkor1.github.io/ta-lib-R/reference/hammer.md),
  [`shooting_star()`](https://serkor1.github.io/ta-lib-R/reference/shooting_star.md),
  [`inverted_hammer()`](https://serkor1.github.io/ta-lib-R/reference/inverted_hammer.md),
  [`hanging_man()`](https://serkor1.github.io/ta-lib-R/reference/hanging_man.md))
  primarily depend on `ShadowLong` and `BodyShort`.
- **Distance-based comparisons**
  ([`kicking()`](https://serkor1.github.io/ta-lib-R/reference/kicking.md),
  [`matching_low()`](https://serkor1.github.io/ta-lib-R/reference/matching_low.md),
  [`counter_attack()`](https://serkor1.github.io/ta-lib-R/reference/counter_attack.md))
  use the `Near`, `Far`, and `Equal` settings.

## Charting patterns

Candlestick patterns integrate with the
[{talib}](https://github.com/serkor1/ta-lib-R/) charting system. Bullish
patterns are marked below the candle, bearish patterns above, and
direction-neutral patterns use a neutral style:

``` r
{
    talib::chart(talib::BTC)
    talib::indicator(talib::doji)
    talib::indicator(talib::engulfing)
}
```

Multiple patterns can be layered on the same chart. Each call to
[`indicator()`](https://serkor1.github.io/ta-lib-R/reference/indicator.md)
adds its markers to the existing price chart.

## Contributing and bug reports

The underlying library, [TA-Lib](https://github.com/TA-Lib/ta-lib), is a
long-standing and well-known library but this R wrapper is still in its
early stage. All contributions, suggestions, and bug reports are
welcome.
