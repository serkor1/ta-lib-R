#' @description
#' `<%= tolower(.fun) %>()` is a generic S3 function that preserves
#' the input [class]: [double] vector in, [double] vector out.
#' 
#' ## Handling of `NA` values
#'
#' Leading `NA`s are always produced for the initial lookback period
#' where insufficient data is available. If the input itself contains
#' `NA`s, the behaviour depends on `na.bridge`:
#'
#' \describe{
#'  \item{`na.bridge = FALSE` (default)}{`NA`s propagate through the
#'    TA-Lib C routine. Because rolling statistics smooth across time,
#'    a single `NA` in the input typically poisons every subsequent
#'    value.}
#'  \item{`na.bridge = TRUE`}{Input `NA`s are stripped, the statistic
#'    is computed on the dense series, and `NA`s are re-inserted at
#'    the original positions. Output length matches input length, but
#'    the computation treats non-consecutive observations as if they
#'    were adjacent - fine for sparse missing values, misleading
#'    across clustered gaps.}
#' }
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
<% if ("timePeriod" %in% fun_args) { %>
#' @param timePeriod ([integer]). Lookback period (window size). A positive [integer]
#'   of [length] 1.
<% } %>
<% if ("na.bridge" %in% fun_args) { %>
#' @param na.bridge ([logical]). A [logical] of [length] 1. [FALSE] by
#'   default. When [FALSE], input `NA`s propagate through the TA-Lib C
#'   routine (the rolling computation typically fills the remaining
#'   output with `NA`). When [TRUE], input `NA` rows are stripped
#'   before computation and re-inserted at the original positions in
#'   the output, causing the statistic to treat non-consecutive
#'   non-`NA` observations as if they were adjacent - see the
#'   **Handling of `NA` values** section above for the consequences.
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
