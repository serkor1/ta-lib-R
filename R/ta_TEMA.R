#' @title Triple Exponential Moving Average (TEMA)
#' @family Overlap Study
#' @export
TEMA <- function(x, n = 10, ...) {
    UseMethod("TEMA")
}

#' @rdname TEMA
#' @usage NULL
#' @export
TEMA.default <- function(x, n = 10, ...) {
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
        4L
    )
}

#' @rdname TEMA
#' @usage NULL
#' @export
TEMA.plotly <- function(x, n = 10, ...) {
    dots <- list(...)
    series <- dots$.series

    tema <- .Call(
        "impl_ta_MA",
        .univariate_series(series),
        as.integer(n),
        4L
    )

    df <- data.frame(
        idx = seq_along(tema),
        tema = as.numeric(tema)
    )

    .plotting_environment$main <- plotly::add_trace(
        x,
        data = df, # bind data here (creates/sets cur_data)
        x = ~idx,
        y = ~tema, # refer to columns, not objects in caller env
        type = "scatter",
        mode = "lines",
        name = sprintf("TEMA(%d)", n),
        inherit = FALSE,
        xaxis = "x",
        yaxis = "y" # ensure it lands on the main panel
    )

    .plotting_environment$main
}
