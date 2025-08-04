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
moving_average_convergence_divergence <- function(x, fast = 12L, slow = 26L, signal = 9L, ...) {
  UseMethod(
    generic = "moving_average_convergence_divergence"
    )
}

#' @export
moving_average_convergence_divergence.default <- function(x, fast = 12L, slow = 26L, signal = 9L, ...) {
  .Call("c_moving_average_convergence_divergence", as.numeric(x), as.integer(fast), as.integer(slow), as.integer(signal))
}