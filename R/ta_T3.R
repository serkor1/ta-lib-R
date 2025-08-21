#' @title T3 Moving Average (T3)
#' @family Overlap Study
#' @export
T3 <- function(x, n = 10, ...) {
    UseMethod("T3")
}

#' @rdname T3
#' @usage NULL
#' @export
T3.default <- function(x, n = 10, ...) {
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
        8L
    )
}

#' @rdname T3
#' @usage NULL
#' @export
T3.plotly <- function(x, n = 10, ...) {
    dots <- list(...)
    series <- dots$.series

    t3 <- .Call(
        "impl_ta_MA",
        .univariate_series(series),
        as.integer(n),
        8L
    )

    df <- data.frame(
        idx = seq_along(t3),
        t3 = as.numeric(t3)
    )

    .plotting_environment$main <- plotly::add_trace(
        x,
        data = df, # bind data here (creates/sets cur_data)
        x = ~idx,
        y = ~t3, # refer to columns, not objects in caller env
        type = "scatter",
        mode = "lines",
        name = sprintf("T3(%d)", n),
        inherit = FALSE,
        xaxis = "x",
        yaxis = "y" # ensure it lands on the main panel
    )

    .plotting_environment$main
}
