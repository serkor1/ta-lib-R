#' @title Bollinger Bands
#'
#' @description 
#' Calculate Bollinger Bands
#'
#' @param x an object
#'
#' @export
bollinger_bands <- function(a, b, c, d, e) {
    .Call("c_bollinger_bands",
               as.numeric(a),
               as.integer(b),
               as.numeric(c),
               as.numeric(d),
               e)
}