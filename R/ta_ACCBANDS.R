#' @title Acceleration Bands
#'
#' @family Overlap Study
#'
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
    assert(is.numeric(x))
    assert(n >= 2)

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

#' @export
acceleration_bands.plotly <- function(
    x,
    n = 10,
    ...
) {
    ## This function
    passed_arguments <- list(
        ...
    )

    ## extract data
    HLC <- passed_arguments$.series

    assert(
        ncol(HLC) == 3,
        "Acceleration bands uses 3 columns. Found ",
        ncol(HLC)
    )

    ## calculate acceleration
    ## bands
    .indicator <- .Call(
        "impl_ta_ACCBANDS",
        .high(HLC),
        .low(HLC),
        .close(HLC),
        as.integer(n)
    )

    ## convert to data.frame
    data_frame <- data.frame(
        idx = seq_along(.indicator),
    )

    ## generate plot
    .chart <- .plotting_environment$main

    for (i in seq_len(ncol(HLC))) {
        local({
            j <- i

            .plotting_environment$main <- plotly::add_lines(
                .chart,
                data = data_frame,
                x = ~idx,
                y = ~ .value[, j],
                inherit = FALSE,
                line = list(
                    color = '#4682b4'
                ),
                showlegend = FALSE,
                legendgroup = 'acceleration_band',
                name = c("Upper Band", "Middle Band", "Lower Band")[j],
            )
        })
    }

    .plotting_environment$main <- plotly::add_ribbons(
        p = .plotting_environment$main,
        inherit = FALSE,
        x = ~ seq_len(nrow(.value)),
        ymin = ~ .value[, 3],
        ymax = ~ .value[, 1],
        fillcolor = plotly::toRGB("#4682b4", alpha = 0.2),
        line = list(
            color = "transparent"
        ),
        showlegend = TRUE,
        legendgroup = 'acceleration_band',
        name = paste0(
            "ACCBANDS"
        )
    )

    .plotting_environment$main
}
