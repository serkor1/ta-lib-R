#' @title Simple Moving Average (SMA)
#' @export
simple_moving_average <- function(x, n = 10, ...) {
    UseMethod(
        "simple_moving_average"
    )
}

#' @export
simple_moving_average.default <- function(x, n = 10, ...) {
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
        "impl_ta_MA", 
        x, 
        as.integer(n),
        0L
    )
}

#' @export
SMA <- simple_moving_average

#' @title Exponential Moving Average (EMA)
#' @export
exponential_moving_average <- function(x, n = 10, ...) {
    UseMethod(
        "exponential_moving_average"
    )
}

#' @export
exponential_moving_average.default <- function(x, n = 10, ...) {
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
        "impl_ta_MA", 
        x, 
        as.integer(n),
        1L
    )
}

#' @export
EMA <- exponential_moving_average

#' @title Weighted Moving Average (WMA)
#' @export
weighted_moving_average <- function(x, n = 10, ...) {
    UseMethod(
        "weighted_moving_average"
    )
}

#' @export
weighted_moving_average.default <- function(x, n = 10, ...) {
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
        "impl_ta_MA", 
        x, 
        as.integer(n),
        2L
    )
}

#' @export
WMA <- weighted_moving_average

#' @title Double Exponential Moving Average (DEMA)
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
    assert(is.numeric(x)); assert(n >= 2)

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

#' @title Triple Exponential Moving Average (TEMA)
#' @export
triple_exponential_moving_average <- function(x, n = 10, ...) {
    UseMethod("triple_exponential_moving_average")
}

#' @export
triple_exponential_moving_average.default <- function(x, n = 10, ...) {
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
    assert(is.numeric(x)); assert(n >= 2)

    ## 1) pass `x` to C 
    .Call(
        "impl_ta_MA", 
        x, 
        as.integer(n), 
        4L
    )
}

#' @export
TEMA <- triple_exponential_moving_average

#' @title Triangular Moving Average (TRIMA)
#' @export
triangular_moving_average <- function(x, n = 10, ...) {
    UseMethod("triangular_moving_average")
}

#' @export
triangular_moving_average.default <- function(x, n = 10, ...) {
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
    assert(is.numeric(x)); assert(n >= 2)

    ## 1) pass `x` to C 
    .Call(
        "impl_ta_MA",
        x, 
        as.integer(n),
        5L
    )
}

#' @export
TRIMA <- triangular_moving_average

#' @title Kaufman’s Adaptive Moving Average (KAMA)
#' @export
kaufman_adaptive_moving_average <- function(x, n = 10, ...) {
    UseMethod("kaufman_adaptive_moving_average")
}

#' @export
kaufman_adaptive_moving_average.default <- function(x, n = 10, ...) {
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
    assert(is.numeric(x)); assert(n >= 2)

    ## 1) pass `x` to C 
    .Call(
        "impl_ta_MA", 
        x, 
        as.integer(n), 
        6L
    )   
}

#' @export
KAMA <- kaufman_adaptive_moving_average

#' @title Mesa Adaptive Moving Average (MAMA)
#' @export
mesa_adaptive_moving_average <- function(x, n = 10, ...) {
    UseMethod("mesa_adaptive_moving_average")
}

#' @export
mesa_adaptive_moving_average.default <- function(x, n = 10, ...) {
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
    assert(is.numeric(x)); assert(n >= 2)

    ## 1) pass `x` to C 
    .Call(
        "impl_ta_MA", 
        x, 
        as.integer(n), 
        7L
    )
}

#' @export
MAMA <- mesa_adaptive_moving_average

#' @title T3 Moving Average (T3)
#' @export
t3_moving_average <- function(x, n = 10, ...) {
    UseMethod("t3_moving_average")
}

#' @export
t3_moving_average.default <- function(x, n = 10, ...) {
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
    assert(is.numeric(x)); assert(n >= 2)
    
    ## 1) pass `x` to C 
    .Call(
        "impl_ta_MA", 
        x, 
        as.integer(n), 
        8L
    )
}

#' @export
T3 <- t3_moving_average