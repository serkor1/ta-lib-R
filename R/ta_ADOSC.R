#' @title Chaikin A/D Oscillator
#' @export
chaikin_AD_oscillator <- function(x, fast = 3, slow = 10, ...) {
    UseMethod(
        "chaikin_AD_oscillator"
    )
}

#' @export
ADOSC <- chaikin_AD_oscillator

#' @export
chaikin_AD_oscillator.default <- function(x, fast = 3, slow = 10, ...) {
    .Call(
        "impl_ta_ADOSC",
        .high(x),
        .low(x),
        .close(x),
        .volume(x),
        as.integer(fast),
        as.integer(slow)
    )
}