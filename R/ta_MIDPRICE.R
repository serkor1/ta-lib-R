#' @title NULL
#' @usage NULL
#' 
#' @template description
#'
#' @templateVar .title Midpoint Price
#' @templateVar .type multivariate
#' @templateVar .fun midpoint_price
#' @templateVar .author Serkan Korkmaz
#'
#' @returns Something
#' @export
midpoint_price <- function(x, n, ...) {
  UseMethod(
    generic = "midpoint_price"
    )
}

#' @export
midpoint_price.default <- function(x, n, ...) {
  ## default behaviour is to
  ## coerce to a `matrix` check that
  ## it is double and then pass to
  ## C-side.

  ## 0) validate input
  ##    and stop the script
  ##    if conditions are not
  ##    met
  x <- as.matrix(x); assert(is.numeric(x))

  .Call("impl_MIDPRICE", x[,1:4], as.integer(n))
}