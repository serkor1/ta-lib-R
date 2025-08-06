#' @title NULL
#' @usage NULL
#' 
#' @template description
#'
#' @templateVar .title Average Price
#' @templateVar .type multivariate
#' @templateVar .fun average_price
#' @templateVar .author Serkan Korkmaz
#'
#' @param x An object coercible to [matrix].
#' @param ... Arguments passed into other methods.
#'
#' ## Title
#' This function calculates the average price of 
#' of a financial asset
#'
#' @returns
#' A [double]-vector of [lenght] N of average prices.
#'
#' @examples
#' ## calculate average
#' ## price
#' average_price(BTC)
#'
#' @export
average_price <- function(x, ...) {
  UseMethod(
    generic = "average_price"
    )
}

#' @export
average_price.default <- function(x, ...) {
  ## default behaviour is to
  ## coerce to a `matrix` check that
  ## it is double and then pass to
  ## C-side.

  ## 0) validate input
  ##    and stop the script
  ##    if conditions are not
  ##    met
  x <- as.matrix(x); assert(is.numeric(x))

  ## 1) pass `x` assuming that
  ##    it follows Open (x[,1]), High (x[,2])
  ##    Low (x[,3]) and Close (x[,4]) 
  .Call("impl_TA_AVGPRICE", x[,1:4])
}