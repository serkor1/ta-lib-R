#' @title Kaufman Adaptive Moving Average
#'
#' @description
#'
#' @export
kaufman_adaptive_moving_average <- function(x, lag) {
    .Call("c_kaufman_adaptive_moving_average", x, as.integer(lag))
}