#' @title NULL
#' @usage NULL
#' 
#' @template description
#'
#' @templateVar .title Three Black Crows
#' @templateVar .type multivariate
#' @templateVar .fun three_black_crows
#' @templateVar .author Serkan Korkmaz
#'
#' @returns Something
#'
#' @export
three_black_crows <- function(x, ...) {
    UseMethod(
        generic = "three_black_crows"
    )
}

#' @export
three_black_crows.default <- function(x, ...) {
  ## default behaviour is to
  ## coerce to a `matrix` check that
  ## it is double and then pass to
  ## C-side.

  ## 0) validate input
  ##    and stop the script
  ##    if conditions are not
  ##    met
  x <- as.matrix(x); assert(is.numeric(x))

  .Call("c_cdl3blackcrows",
        as.numeric(x[,1]),
        as.numeric(x[,2]),
        as.numeric(x[,3]),
        as.numeric(x[,4]))
}


