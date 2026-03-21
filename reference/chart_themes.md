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

## See also

Other Charting:
[`chart()`](https://serkor1.github.io/ta-lib-R/reference/chart.md),
[`indicator()`](https://serkor1.github.io/ta-lib-R/reference/indicator.md),
[`set_theme()`](https://serkor1.github.io/ta-lib-R/reference/set_theme.md)

## Examples

``` r
## list available themes
talib::set_theme()
#> [1] "default"           "hawks_and_doves"   "payout"           
#> [4] "tp_slapped"        "trust_the_process"

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
