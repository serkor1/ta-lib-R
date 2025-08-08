#' @title Doji
#' @export
doji <- function(x, ...) {
    UseMethod(
        "doji"
    )
}

#' @export
CDLDOJI <- doji

#' @export
doji.default <- function(x, ...) {
    .Call(
        "impl_ta_CDLDOJI",
        .open(x),
        .high(x),
        .low(x),
        .close(x),
        as.logical(getOption("talib.normalize", TRUE))
    )
}