# Set or List Chart Themes

Apply a named color theme to the charting system, override individual
theme properties, or list all available theme names. The themes are
inspired by [chartthemes.com](https://chartthemes.com/).

Theme changes take effect immediately and apply to all subsequent
[`chart()`](https://serkor1.github.io/ta-lib-R/reference/chart.md) and
[`indicator()`](https://serkor1.github.io/ta-lib-R/reference/indicator.md)
calls.

## Usage

``` r
set_theme(name, ...)
```

## Arguments

- name:

  An optional [character](https://rdrr.io/r/base/character.html) string
  matching one of the available theme names. Partial matching is
  supported. If omitted (and no `...` overrides are given), returns the
  available theme names instead.

- ...:

  Named color overrides applied after the base theme. Valid names
  include any theme property: `bearish_body`, `bearish_wick`,
  `bearish_border`, `bullish_body`, `bullish_wick`, `bullish_border`,
  `background_color`, `foreground_color`, `text_color`, `gridcolor`,
  `threshold_color`, and `colorway` (a character vector of up to 10
  colors).

## Value

When called without arguments, a
[character](https://rdrr.io/r/base/character.html) vector of available
theme names. Otherwise, invisibly returns the internal theme environment
after modification.

## Details

`set_theme` supports three usage patterns:

- `set_theme()`:

  Returns a character vector of available theme names.

- `set_theme("payout")`:

  Applies the named theme.

- `set_theme$payout`:

  Applies the named theme via `$` syntax (supports tab-completion in
  interactive sessions).

Themes can be combined with individual color overrides. When both `name`
and `...` are provided, the base theme is applied first, then the
overrides are applied on top:

    # Apply "payout" but with a custom background
    set_theme("payout", background_color = "#000000")

It is also possible to override individual properties without selecting
a theme:

    # Change only the bearish candle color
    set_theme(bearish_body = "#FF0000")

See
[chart_themes](https://serkor1.github.io/ta-lib-R/reference/chart_themes.md)
for a full description of all available themes and their color
properties.

## See also

[chart_themes](https://serkor1.github.io/ta-lib-R/reference/chart_themes.md)
for descriptions of each theme,
[`chart()`](https://serkor1.github.io/ta-lib-R/reference/chart.md) for
creating charts.

Other Charting:
[`chart()`](https://serkor1.github.io/ta-lib-R/reference/chart.md),
[`chart_themes`](https://serkor1.github.io/ta-lib-R/reference/chart_themes.md),
[`indicator()`](https://serkor1.github.io/ta-lib-R/reference/indicator.md)

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
