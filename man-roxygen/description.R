#' @description
#' The `<%= tolower(.fun) %>()` is a generic S3 function that builds upon 'type-safe'-esque workflows limited to classes in in base `R`, and the package-wide
#' dependencies. Ie. [class] in, [class] out. Each method is a soft wrapper of [model.frame] and therefore the OHLC-V series must be coercible to a [data.frame].
#' This rule does not transfer to indicators that uses univariate series, unless passed as a 1-column [data.frame] or [matrix]. In such cases, if univariate series
#' is passed as a [vector] the function calculates the indicator 'as is', and returns a [data.frame] if the indicator itself is also a univariate series.
#'
#' The indicator, by default, follows its mathematical definition. However, the `cols` argument allows for simple rearrangement of the definition by passing relevant
#' columns in a custom order. Refer to the details-section for more on the calculation of the indicators.
#'
#' @inheritParams generic_documentation
#'
#' @author <%= .author %>
#'
#' @concept finance
#' @concept technical analysis
#' @concept trading
#' @concept algorithmic trading
#'
#' @examples
#' ## load Bitcoin (BTC)
#' ## series
#' data(BTC, package = "talib")
#'
#' ## calculate the indicator
#' ## for Bitcoin (BTC)
#' output <- talib::<%= .fun %>(BTC)
#'
#' ## display the results
#' tail(output)
#'
#' ## visualize the indicator
#' ## with candlesticks
#' ##
#' ## see ?talib::chart or ?talib::indicator
#' ## for more details
#' {
#'  ## chart OHLC-V
#'  ## series with candlesticks
#'  talib::chart(BTC)
#'
#'  ## chart indicator
#'  ## with default values
#'  talib::indicator(
#'      talib::<%= .fun %>()
#'  )
#' }
