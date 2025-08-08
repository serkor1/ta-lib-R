#' @title Evening Doji Star
#' @export
evening_doji_star <- function(x, penetration = 0.1, ...) {
    UseMethod(
        "evening_doji_star"
    )
}

#' @export
CDLEVENINGDOJISTAR <- evening_doji_star

#' @export
evening_doji_star.default <- function(x, penetration = 0.1, ...) {
    .Call(
        "impl_ta_CDLEVENINGDOJISTAR",
        .open(x),
        .high(x),
        .low(x),
        .close(x),
        penetration,
        as.logical(getOption("talib.normalize", TRUE))
    )
}