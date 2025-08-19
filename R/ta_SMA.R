#' @title Simple Moving Average (SMA)
#' 
#' @description
#' A short description...
#' 
#' @param x fisk
#' 
#' @export
simple_moving_average <- function(x, n = 10, ...) {
    UseMethod(
        "simple_moving_average"
    )
}

#' @title Simple Moving Average (SMA)
#' 
#' @description
#' A short description...
#' 
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

#' @title Simple Moving Average (SMA)
#' 
#' @description
#' A short description...
#' 
#' @export
SMA <- simple_moving_average

#' @title Simple Moving Average (SMA)
#' 
#' @description
#' A short description...
#' 
#' @export
simple_moving_average.plotly <- function(
    x,
    n = 10, 
    ...) {

        ## extract arguments
        ## from ellipsis
        dots <- list(...)
        series <- dots$.series

        ## generate SMA values
        ## from C as all values
        ## are pre-validated
        .output <- .Call(
            "impl_ta_MA",
            series,
            as.integer(n),
            0L
        )
        
        ## update the price chart
        ## inside the plotting environment
        ## if not set, the plots do not --well-- update
        .plotting_environment$price_chart <- plotly::add_lines(
            x,
            x = ~1:length(.output),
            y = ~.output,
            name = paste0("SMA(", n, ")"),
            inherit = FALSE
        )

        .plotting_environment$price_chart
}

