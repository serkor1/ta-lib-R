#' @title Doji Star
#' @export
doji_star <- function(x, ...) {
    UseMethod(
        "doji_star"
    )
}

#' @export
CDLDOJISTAR <- doji_star

#' @export
doji_star.default <- function(x, ...) {
    .Call(
        "impl_ta_CDLDOJISTAR",
        .open(x),
        .high(x),
        .low(x),
        .close(x)
    )
}