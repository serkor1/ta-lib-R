#' @title Acceleration Bands
#' @export
acceleration_bands <- function(x, n = 10, ...) {
    UseMethod("acceleration_bands")
}

#' @export
ACCBANDS <- acceleration_bands

#' @export
acceleration_bands.default <- function(x, n = 10, ...) {
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
    assert(is.numeric(x)); assert(n >= 2);

    ## 1) pass `x` assuming that it 
    ##    follows OHLC-V structure 
    .Call(
        "impl_ta_ACCBANDS",
        .high(x), 
        .low(x), 
        .close(x), 
        as.integer(n)
    )
}