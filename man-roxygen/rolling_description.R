#' @description
#' `<%= tolower(.fun) %>()` is a generic S3 function that preserves
#' the input [class]: [double] vector in, [double] vector out.
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
<%
	if (all(c("x","y") %in% names(formals(.fun))))
{ %>
#' @param x,y (([double]), ([double])). A pair of [double] vectors of equal [length].
<% } else { %>
#' @param x ([double]). A [double] vector.
#'
<% } %>
<% fun_args <- names(formals(.fun)) %>
<% if ("n" %in% fun_args) { %>
#' @param n ([integer]). Lookback period (window size). A positive [integer]
#'   of [length] 1.
<% } %>
<% if ("na.ignore" %in% fun_args) { %>
#' @param na.ignore ([logical]). A [logical] of [length] 1. [FALSE] by default.
#'   If [TRUE], `NA`s in the input are stripped before calculation and
#'   re-inserted at their original positions in the output.
<% } %>
<% if ("..." %in% fun_args) { %>
#' @param ... Additional parameters.
<% } %>
#'
#' @author <%= .author %>
#'
#' @concept finance
#' @concept technical analysis
#' @concept trading
#' @concept algorithmic trading
#'
<%
	if (all(c("x","y") %in% names(formals(.fun))))
{ %>
#' @examples
#' ## load Bitcoin (BTC)
#' ## series
#' data(BTC, package = "talib")
#'
#' ## calculate the rolling statistic
#' ## between Open and Close
#' output <- talib::<%= .fun %>(x = BTC[[1]], y = BTC[[4]])
#'
#' ## display the results
#' utils::tail(output)
#' 
<% } else { %>
#' @examples
#' ## load Bitcoin (BTC)
#' ## series
#' data(BTC, package = "talib")
#'
#' ## calculate the indicator
#' ## Open
#' output <- talib::<%= .fun %>(x = BTC[[1]])
#' 
#' ## display the results
#' utils::tail(output)
#' 
<% } %>
