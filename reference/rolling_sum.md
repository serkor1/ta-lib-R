# Rolling Sum

The `rolling_sum()` is a generic S3 function that builds upon
'type-safe'-esque workflows limited to classes in in base `R`, and the
package-wide dependencies. Ie.
[class](https://rdrr.io/r/base/class.html) in,
[class](https://rdrr.io/r/base/class.html) out. Each method is a soft
wrapper of [model.frame](https://rdrr.io/r/stats/model.frame.html) and
therefore the OHLC-V series must be coercible to a
[data.frame](https://rdrr.io/r/base/data.frame.html). This rule does not
transfer to indicators that uses univariate series, unless passed as a
1-column [data.frame](https://rdrr.io/r/base/data.frame.html) or
[matrix](https://rdrr.io/r/base/matrix.html). In such cases, if
univariate series is passed as a
[vector](https://rdrr.io/r/base/vector.html) the function calculates the
indicator 'as is', and returns a
[data.frame](https://rdrr.io/r/base/data.frame.html) if the indicator
itself is also a univariate series.

The indicator, by default, follows its mathematical definition. However,
the `cols` argument allows for simple rearrangement of the definition by
passing relevant columns in a custom order. Refer to the details-section
for more on the calculation of the indicators.

## Usage

``` r
rolling_sum(x, n = 10, ...)
```

## Arguments

- x:

  An OHLC-V series that is coercible to
  [data.frame](https://rdrr.io/r/base/data.frame.html). The function
  assumes that all columns are named in lowercase and order invariant.

- n:

  An [integer](https://rdrr.io/r/base/integer.html) of
  [length](https://rdrr.io/r/base/length.html) 1.

- ...:

  Additional parameters passed into
  [model.frame](https://rdrr.io/r/stats/model.frame.html)

## Value

An object of same [class](https://rdrr.io/r/base/class.html) and
[length](https://rdrr.io/r/base/length.html) of `x`:

`r generate_returns_section(rolling_sum(talib::BTC))`

## See also

Other Rolling Statistic:
[`rolling_beta()`](https://serkor1.github.io/ta-lib-R/reference/rolling_beta.md),
[`rolling_correlation()`](https://serkor1.github.io/ta-lib-R/reference/rolling_correlation.md),
[`rolling_max()`](https://serkor1.github.io/ta-lib-R/reference/rolling_max.md),
[`rolling_min()`](https://serkor1.github.io/ta-lib-R/reference/rolling_min.md),
[`rolling_standard_deviation()`](https://serkor1.github.io/ta-lib-R/reference/rolling_standard_deviation.md),
[`rolling_variance()`](https://serkor1.github.io/ta-lib-R/reference/rolling_variance.md)

## Author

Serkan Korkmaz

## Examples

``` r
## load Bitcoin (BTC)
## series
data(BTC, package = "talib")

## calculate the indicator
## for Bitcoin (BTC)
output <- talib::rolling_sum(BTC)
#> Error in rolling_sum.default(BTC): 'list' object cannot be coerced to type 'double'

## display the results
utils::tail(output)
#> Error: object 'output' not found

## visualize the indicator
## with candlesticks
##
## see ?talib::chart or ?talib::indicator
## for more details
{
 ## chart OHLC-V
 ## series with candlesticks
 talib::chart(BTC)

 ## chart indicator
 ## with default values
 talib::indicator(
     talib::rolling_sum
 )
}
#> Error in rolling_sum.default(x = structure(list(x = structure(list(visdat = list(    `382122a04f` = function ()     plotlyVisDat), cur_data = "382122a04f", attrs = list(`382122a04f` = list(    x = ~idx, open = ~open, close = ~close, high = ~high, low = ~low,     increasing = list(line = list(color = "#65a479", width = 1.25),         fillcolor = "rgba(101,164,121,1)"), decreasing = list(        line = list(color = "#d5695d", width = 1.25), fillcolor = "rgba(213,105,93,1)"),     showlegend = FALSE, alpha_stroke = 1, sizes = c(10, 100),     spans = c(1, 20), type = "candlestick")), layout = list(width = NULL,     height = NULL, margin = list(b = 40, l = 60, t = 25, r = 10)),     source = "A", config = list(modeBarButtonsToAdd = c("drawline",     "drawrect", "eraseshape", "hoverclosest", "hovercompare"),         showSendToCloud = FALSE, displaylogo = FALSE), layoutAttrs = list(        `382122a04f` = list(paper_bgcolor = "#2b3139", plot_bgcolor = "#2b3139",             font = list(size = 14, color = "#848e9c"), yaxis = list(                title = "", gridcolor = "#40454c"), xaxis = list(                title = "", gridcolor = "#40454c", rangeslider = list(                  visible = FALSE, thickness = 0.05), tickvals = integer(0),                 tickmode = "auto", ticktext = NULL), showlegend = TRUE,             legend = list(orientation = "h", x = 0, y = 100,                 yref = "container", title = list(text = "<b>Indicators:</b>",                   font = list(size = 16))), title = list(text = "<b>Ticker:</b> BTC <br><sub><b>N:</b> 366 <b>Period:</b> 2024-01-01 01:00:00 - 2024-12-31 01:00:00 </sub>",                 font = list(size = 20), x = 1, xref = "paper",                 xanchor = "right")))), TOJSON_FUNC = function (x,     ...) {    jsonlite::toJSON(x, digits = 50, auto_unbox = TRUE, force = TRUE,         null = "null", na = "null", time_format = "%Y-%m-%d %H:%M:%OS6",         ...)}), width = NULL, height = NULL, sizingPolicy = list(defaultWidth = "100%",     defaultHeight = 400, padding = 0, fill = NULL, viewer = list(        defaultWidth = NULL, defaultHeight = NULL, padding = NULL,         fill = TRUE, suppress = FALSE, paneHeight = NULL), browser = list(        defaultWidth = NULL, defaultHeight = NULL, padding = NULL,         fill = TRUE, external = FALSE), knitr = list(defaultWidth = NULL,         defaultHeight = NULL, figure = TRUE)), dependencies = list(    structure(list(name = "typedarray", version = "0.1", src = list(        file = "htmlwidgets/lib/typedarray"), meta = NULL, script = "typedarray.min.js",         stylesheet = NULL, head = NULL, attachment = NULL, package = "plotly",         all_files = FALSE), class = "html_dependency"), structure(list(        name = "jquery", version = "3.5.1", src = list(file = "lib/jquery"),         meta = NULL, script = "jquery.min.js", stylesheet = NULL,         head = NULL, attachment = NULL, package = "crosstalk",         all_files = TRUE), class = "html_dependency"), structure(list(        name = "crosstalk", version = "1.2.2", src = list(file = "www"),         meta = NULL, script = "js/crosstalk.min.js", stylesheet = "css/crosstalk.min.css",         head = NULL, attachment = NULL, package = "crosstalk",         all_files = TRUE), class = "html_dependency"), structure(list(        name = "plotly-htmlwidgets-css", version = "2.11.1",         src = list(file = "htmlwidgets/lib/plotlyjs"), meta = NULL,         script = NULL, stylesheet = "plotly-htmlwidgets.css",         head = NULL, attachment = NULL, package = "plotly", all_files = FALSE), class = "html_dependency"),     structure(list(name = "plotly-main", version = "2.11.1",         src = list(file = "htmlwidgets/lib/plotlyjs"), meta = NULL,         script = "plotly-latest.min.js", stylesheet = NULL, head = NULL,         attachment = NULL, package = "plotly", all_files = FALSE), class = "html_dependency")),     elementId = NULL, preRenderHook = function (p, registerFrames = TRUE)     {        UseMethod("plotly_build")    }, jsHooks = list()), class = c("plotly", "htmlwidget"), package = "plotly")): 'list' object cannot be coerced to type 'double'
```
