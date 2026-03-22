#' @description
#' `<%= tolower(.fun) %>()` is a generic S3 function that preserves
#' the input [class]: [data.frame] in, [data.frame] out; [matrix] in,
#' [matrix] out.
#'
#' 
<% if (any(grepl(pattern = "cols", x = names(formals(.fun))))) { %>

<% n_vars <- length(all.vars(as.formula(.formula))) %>
<% if (n_vars == 1) { %>
#' `<%= tolower(.fun) %>()` also accepts a [double] vector, in which case the indicator is calculated directly without column selection. When the result has a single column it is simplified to a [double] vector; otherwise the full `n` by `k` [matrix] is returned.
#' 
<% } %>
#'
#' ## Handling of <NA>-values
#'
#' Leading `NA`s are always produced for the initial lookback period
#' where insufficient data is available. If the input itself contains
#' `NA`s they are passed through to the underlying C routine, which
#' can cause the **entire** output to be filled with `NA`s. Set
#' `na.ignore = TRUE` to strip `NA`s before calculation and
#' re-insert them at their original positions in the output.
#'
#' 
#' @param x An OHLC-V series coercible to [data.frame].
<% if (n_vars == 1) { %>
#' Alternatively, `x` may also be supplied as a [double] vector.
<% } %>
#'
#' @param cols ([formula]). An optional `<%= length(all.vars(as.formula(.formula))) %>`-variable [formula] selecting columns from `x` via [model.frame].
#'  Defaults to `<%= deparse(as.formula(.formula)) %>`.
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
