#' @title Double Exponential Moving Average (DEMA)
#'
#' @family Overlap Study
#'
#' @export
double_exponential_moving_average <- function(x, n = 10, ...) {
    UseMethod("double_exponential_moving_average")
}

#' @export
double_exponential_moving_average.default <- function(x, n = 10, ...) {
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
        stop("`x` must be a numeric vector")
    }
    assert(is.numeric(x))
    assert(n >= 2)

    ## 1) pass `x` to C
    .Call(
        "impl_ta_MA",
        x,
        as.integer(n),
        3L
    )
}

#' @export
DEMA <- double_exponential_moving_average
