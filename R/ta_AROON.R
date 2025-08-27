#' @title Aroon
#'
#' @description
#'
#' @family Momentum Indicator
#'
#' @export
aroon <- function(x, n, ...) {
  UseMethod(
    generic = "aroon"
  )
}

#' @export
aroon.default <- function(x, n, ...) {
  ## default behaviour is to
  ## coerce to a `matrix` check that
  ## it is double and then pass to
  ## C-side.

  ## 0) validate input
  ##    and stop the script
  ##    if conditions are not
  ##    met
  if (!is.matrix(x)) {
    x <- as.matrix(x)
  }
  assert(is.numeric(x))

  ## 1) pass `x` assuming that
  ##    it follows Open (x[,1]), High (x[,2])
  ##    Low (x[,3]) and Close (x[,4])
  .Call("impl_ta_AROON", .high(x), .low(x), as.integer(n))
}
