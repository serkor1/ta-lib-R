#' @title Bollinger Bands
#' @export
bollinger_bands <- function(x, ma = SMA(n = 10), up = 2, down = 2,  ...) {
    UseMethod(
        generic = "bollinger_bands"
    )
}

#' @export
BBANDS <- bollinger_bands

#' @export
bollinger_bands.default <- function(x, ma = SMA(n = 10), up = 2, down = 2,  ...) {
    ## default behaviour is to
    ## coerce to a `matrix` check that
    ## it is double and then pass to
    ## C-side.
    ma <- map_maType_call(substitute(ma))

    ## 0) validate input
    ##    and stop the script
    ##    if conditions are not
    ##    met
    if (!is.matrix(x)) {
        x <- as.matrix(x)
    }
    assert(is.numeric(x)); assert(ma$n >= 2);

    ## 1) pass `x` assuming that it 
    ##    follows OHLC-V structure 
    .Call(  
        "impl_ta_BBANDS",
        x,
        ma$n,
        as.numeric(up),
        as.numeric(down),
        as.integer(ma$maType)
    )
}