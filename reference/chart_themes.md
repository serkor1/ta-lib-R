# Chart Themes

The charting system ships with a set of built-in color themes inspired
by [chartthemes.com](https://chartthemes.com/). Each theme controls
candle colors, background, text, grid lines, and a 10-color palette
(colorway) used to distinguish indicator lines.

Use
[`ggplot2::set_theme()`](https://ggplot2.tidyverse.org/reference/get_theme.html)
to apply or list themes.

## Details

### Available Themes

- `default`:

  A dark theme with cyan and steel-blue tones. Light (`#E0FFFF`) bullish
  candles on a near-black (`#141414`) background with a cool blue
  (`#4682B4`) bearish candle. The colorway spans icy blues through teal
  and soft purple.

- `hawks_and_doves`:

  A light, grayscale theme with a white background. Candles use shades
  of gray, making it suitable for print or presentations where color is
  secondary. The colorway uses muted, accessible tones.

- `payout`:

  A dark teal theme on a near-black (`#1A1A1A`) background. Bullish
  candles are teal (`#008080`), bearish candles are dark slate
  (`#2F4F4F`). The colorway follows the default Plotly palette.

- `tp_slapped`:

  A bright theme on a light gray (`#ECF0F1`) background. Red (`#E74C3C`)
  bearish and teal (`#1ABC9C`) bullish candles provide strong visual
  contrast. The colorway uses vivid, saturated colors.

- `trust_the_process`:

  A subtle, earth-toned theme on a light gray (`#F5F5F5`) background.
  Both bull and bear candles use shades of gray, keeping the focus on
  indicator lines. The colorway uses muted natural tones.

- `bloomberg_terminal`:

  A dark theme on a near-black (`#0E1017`) background with orange
  (`#FF8F40`) bullish and neutral-gray (`#BBB9B2`) bearish candles.
  Inspired by the Bloomberg Terminal interface. Colorblind-friendly (see
  below).

- `limit_up`:

  A dark monochrome theme on a near-black (`#121212`) background.
  Candles use only luminance to encode direction (light-gray bullish vs
  dark-gray bearish). Colorblind-friendly (see below).

- `bid_n_ask`:

  A light theme on an azure (`#F0FFFF`) background with steel-blue
  (`#4682B4`) bullish and tomato-red (`#FF6347`) bearish candles. The
  classic blue-vs-red trading pair. Colorblind-friendly (see below).

### Colorblind-Friendly Themes

The following themes encode bull/bear direction in ways that remain
distinguishable under the most common color-vision deficiencies. The
colorways for `bloomberg_terminal`, `limit_up`, and `bid_n_ask` are
derived from the Okabe & Ito (2008) qualitative palette, the de-facto
standard for accessible scientific visualization.

- `limit_up`, `hawks_and_doves`, `trust_the_process`:

  Encode direction with luminance only. Safe under deuteranopia,
  protanopia, tritanopia, and full achromatopsia.

- `bloomberg_terminal`:

  Orange + neutral gray. Safe under all three CVD types thanks to
  Okabe-Ito-style hue separation.

- `default`, `payout`:

  Cyan/teal + blue or dark slate. Safe under all three CVD types — the
  color pair sits inside the blue-yellow axis that CVD users perceive
  normally.

- `bid_n_ask`:

  Blue + red. Safe under deuteranopia and protanopia (the most common
  forms, affecting ~8% of males); the pair separates more weakly under
  tritanopia.

`tp_slapped` is the only built-in that uses a teal/red pair adjacent to
the red-green CVD axis; prefer the themes above when accessibility
matters.

### Theme Properties

Each theme sets the following color properties:

- Candle colors:

  `bearish_body`, `bearish_wick`, `bearish_border`, `bullish_body`,
  `bullish_wick`, `bullish_border`

- General colors:

  `background_color`, `foreground_color` (axes and borders),
  `text_color`

- Grid and reference:

  `gridcolor`, `threshold_color` (horizontal reference lines such as
  overbought/oversold levels)

- Colorway:

  A vector of 10 colors cycled through for indicator lines and legends

Any of these properties can be individually overridden via the `...`
argument to
[`ggplot2::set_theme()`](https://ggplot2.tidyverse.org/reference/get_theme.html).

## References

Okabe, M. & Ito, K. (2008). *Color Universal Design (CUD): How to make
figures and presentations that are friendly to colorblind people.*
<https://jfly.uni-koeln.de/color/>

## See also

Other Charting:
[`chart()`](https://serkor1.github.io/ta-lib-R/reference/chart.md),
[`indicator()`](https://serkor1.github.io/ta-lib-R/reference/indicator.md),
[`set_theme()`](https://serkor1.github.io/ta-lib-R/reference/set_theme.md)

## Examples

``` r
## list available themes
talib::set_theme()
#> [1] "default"            "hawks_and_doves"    "payout"            
#> [4] "tp_slapped"         "trust_the_process"  "bloomberg_terminal"
#> [7] "limit_up"           "bid_n_ask"         

## apply a theme by name
talib::set_theme("payout")

## apply a theme with custom overrides
talib::set_theme(
  "hawks_and_doves",
  background_color = "#FAFAFA"
)

## override individual properties
## without switching theme
talib::set_theme(
  bearish_body = "#FF4444",
  bullish_body = "#44FF44"
)

## reset to default theme
talib::set_theme("default")
```
