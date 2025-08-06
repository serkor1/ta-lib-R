#' @title NULL
#' @usage NULL
#' 
#' @template description
#'
#' @templateVar .title Moving Average Convergence/Divergence
#' @templateVar .type multivariate
#' @templateVar .fun moving_average_convergence_divergence
#' @templateVar .author Serkan Korkmaz
#'
#' @returns Something
#' @export
moving_average_convergence_divergence <- function(
  x, 
  fast = 12, 
  slow = 26, 
  signal = 9, 
  ...) {

  UseMethod(
    generic = "moving_average_convergence_divergence"
    )
}

#' @export
moving_average_convergence_divergence.default <- function(
  x, 
  fast = 12, 
  slow = 26, 
  signal = 9,
  ...) {

    ## default behaviour is to
    ## check if its a numeric vector
    ## 
    ## No coercing here as it might
    ## lead to overflow

    ## 0) validate input
    ##    and stop the script
    ##    if conditions are not
    ##    met
    if (!is.null(dim(x))) {
        stop("`x` has to be a double vector")
    }
    assert(is.numeric(x)); assert(fast >= 2); 
    assert(slow >= 2); assert(signal >= 1);

  .Call(
    .NAME = "impl_ta_MACD", 
    x, 
    as.integer(fast), 
    as.integer(slow), 
    as.integer(signal)
  )
}