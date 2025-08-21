#' @title Chaikin A/D Line
#'
#'
#' @family Volume Indicator
#'
#' @export
chaikin_AD_line <- function(x, ...) {
    UseMethod(
        "chaikin_AD_line"
    )
}

#' @export
AD <- chaikin_AD_line

#' @export
chaikin_AD_line.default <- function(x, ...) {
    .Call(
        "impl_ta_AD",
        .high(x),
        .low(x),
        .close(x),
        .volume(x)
    )
}
