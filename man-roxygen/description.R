#' @description
#' The `<%= tolower(.fun) %>()` is a generic S3 function that builds upon 'type-safe'-esque workflows limited to classes in in base `R`, and the package-wide
#' dependencies. Ie. [class] in, [class] out. Each method is a soft wrapper of [model.frame] and therefore the OHLC-V series must be coercible to a [data.frame].
#'
#' 
<% if (any(grepl(pattern = "cols", x = names(formals(.fun))))) { %>

<% n_vars <- length(all.vars(as.formula(.formula))) %>
#' `<%= tolower(.fun) %>()` also accepts a [double] vector in which case the indicator is calculated 'as-is' without passing through [model.frame]. `<%= tolower(.fun) %>()` returns an `n` by `k` [matrix] computed in C by default. When `k = 1`, the result is simplified to a [double] vector; for `k > 1`, the full `n` by `k` [matrix] is returned.
#' 
#' @param x An OHLC-V series that is coercible to [data.frame].
<% if (n_vars == 1) { %>
#' Alternatively, `x` may also be supplied as a [double] vector.
<% } %>
#'
#' @param cols ([formula]). An optional `<%= length(all.vars(as.formula(.formula))) %>` variable [formula] passed into [model.frame]. Internally uses 
#'  `<%= deparse(as.formula(.formula)) %>` by default.
#' 
<% } %>
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
<% if (grepl(pattern = "Price Transform", x = .family)) { %>
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
#' utils::tail(output)

<% } else { %>
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
#' utils::tail(output)
#'
#' ## visualize the indicator
#' ## with talib::chart()
#' ##
#' ## see ?talib::chart or ?talib::indicator
#' ## for more details
#' {
#'  ## chart OHLC-V
#'  ## series with talib::chart()
#'  talib::chart(BTC)
#'
#'  ## chart indicator
#'  ## with default values
#'  talib::indicator(
#'      talib::<%= .fun %>
#'  )
#' }

<% } %>
