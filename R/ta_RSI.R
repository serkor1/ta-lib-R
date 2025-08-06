#' @title Relative Strength Index
#' @export
relative_strength_index <- function(x, n, ...) {
    UseMethod(
        "relative_strength_index"
    )
}

#' @export
relative_strength_index.default <- function(x, n, ...) {
    ## default behaviour is to
    ## check if its a numeric vector
    ## 
    ## No coercing here as it might
    ## lead to overflow

    ## 0) validate input
    ##    and stop the script
    ##    if conditions are not
    ##    met
    if (!is.null(dim(x))) {
        stop("`x` has to be a double vector")
    }
    assert(is.numeric(x)); assert(n >= 2)

    ## 1) pass `x` to C 
    .Call(
        .NAME = "impl_ta_RSI", 
        x, 
        as.integer(n)
    )
}