#' @title Bollinger Bands
#' @export
bollinger_bands <- function(x, n = 10, ...) {
    UseMethod(
        generic = "bollinger_bands"
    )
}

#' @export
bollinger_bands.default <- function(x, n = 10, ...) {
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
        .NAME = "impl_ta_BBANDS",
        .high(x),
        .low(x),
        .close(x),
        as.integer(n)
    )
}