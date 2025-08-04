#' @title Weighted Moving Average
#'
#' @export
weighted_moving_average <- function(x, n) {
  .Call("c_weighted_moving_average", as.numeric(x), as.integer(n))
}