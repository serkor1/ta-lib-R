#' @title Ultimate Oscillator
#' @family Momentum Indicator
#' @export
ultimate_oscillator <- function(x, n = c(7, 14, 28), ...) {
    UseMethod(
        "ultimate_oscillator"
    )
}

#' @export
ultimate_oscillator.default <- function(x, n = c(7, 14, 28), ...) {
    ## default behaviour is to
    ## coerce to a `matrix` check that
    ## it is double and then pass to
    ## C-side.

    ## 0) validate input
    ##    and stop the script
    ##    if conditions are not
    ##    met
    if (!is.matrix(x)) {
        x <- as.matrix(x)
    }
    if (!length(n) < 3) {
        stop("`n` has to be a vector of length 3")
    }
    assert(is.numeric(x))
    assert(all(n >= 1))

    ## 1) pass `x` assuming that it
    ##    follows OHLC-V structure
    .Call(
        .NAME = "impl_ta_ULTOSC",
        .high(x),
        .low(x),
        .close(x),
        as.integer(n[1]),
        as.integer(n[2]),
        as.integer(n[3]),
    )
}
