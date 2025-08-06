#' @export
aroon <- function(x, n) {
    .Call("impl_ta_AROON",x[,2], x[,3], as.integer(n))
} 

#' @export
aroonosc <- function(x, n) {
    .Call("impl_ta_AROONOSC",x[,2], x[,3], as.integer(n))
} 