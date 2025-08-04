#' @title NULL
#' @usage NULL
#' 
#' @template description
#'
#' @templateVar .title Median Price
#' @templateVar .type multivariate
#' @templateVar .fun median_price
#' @templateVar .author Serkan Korkmaz
#'
#' @returns Something
#' @export
median_price <- function(x, ...) {
  UseMethod(
    generic = "median_price"
    )
}

#' @export
median_price.default <- function(x, ...) {
  ## default behaviour is to
  ## coerce to a `matrix` check that
  ## it is double and then pass to
  ## C-side.

  ## 0) validate input
  ##    and stop the script
  ##    if conditions are not
  ##    met
  x <- as.matrix(x); assert(is.numeric(x))

  .Call("c_median_price", x[,1:4])
}