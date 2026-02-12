#' @description 
#' The `<%= tolower(.fun) %>()` is a generic S3 function that builds upon 'type-safe'-esque workflows limited to classes in in base `R`, and the package-wide dependencies. Ie. [class] in, [class] out.
#' 
#' ## Handling of <NA>-values
#' 
#' `<%= tolower(.fun) %>()` iterates over valid values, and returns `NA` for the remaing part of series. 
#'  
#' 
<%
	if (all(c("x","y") %in% names(formals(.fun))))
{ %>
#' @param x,y (([double]), ([double])). A pair of vectors.
<% } else { %>
#' @param x ([double]). A vector.
#' 
<% } %>
#' @inheritParams generic_documentation
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
