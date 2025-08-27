#' @title Acceleration Bands
#'
#' @family Overlap Study
#'
#' @export
acceleration_bands <- function(
  x,
  n = 10,
  cols,
  ...
) {
  UseMethod("acceleration_bands")
}

#' @aliases acceleration_bands
#' @export
ACCBANDS <- acceleration_bands

#' @export
acceleration_bands.default <- function(
  x,
  cols,
  n = 10,
  ...
) {
  ## check input
  ## cols if passed
  if (!missing(cols)) {
    assert(
      is.formula(cols),
      paste0(
        "'cols' has to be <",
        class(~s),
        ">. ",
        "Got <",
        class(cols),
        ">."
      )
    )
    assert(
      length(all.vars(cols)) == 3,
      paste0(
        "'cols' has to be length 3. ",
        "Got length ",
        length(all.vars(cols))
      )
    )
  }

  HLC <- series(
    formula = cols,
    formula_default = ~ open + high + close,
    data = x,
    ...
  )

  assert(n >= 2)

  ## 1) pass `x` assuming that it
  ##    follows OHLC-V structure
  as.data.frame(
    .Call(
      "impl_ta_ACCBANDS",
      HLC[[1]],
      HLC[[2]],
      HLC[[3]],
      as.integer(n)
    )
  )
}

#' @aliases acceleration_bands
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
  ## bands and return as
  ## data.frame
  .indicator <- as.data.frame(
    .Call(
      "impl_ta_ACCBANDS",
      HLC[[1]],
      HLC[[2]],
      HLC[[3]],
      as.integer(n)
    )
  )

  .indicator$idx <- 1:nrow(.indicator)

  ## add upper, middle and lower bands
  ## to the main chart - wrapped in local
  ## to circumvent lazy evaluation.
  ##
  ## NOTE: Otherwise it will only evaluate
  ##       and add the last element
  for (i in seq_len(ncol(HLC))) {
    local({
      j <- i

      .plotting_environment$main <- plotly::add_lines(
        .plotting_environment$main,
        data = .indicator,
        x = ~idx,
        y = ~ .indicator[, j],
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
    data = .indicator,
    x = ~idx,
    ymin = ~ .indicator[, 3],
    ymax = ~ .indicator[, 1],
    fillcolor = plotly::toRGB("#4682b4", alpha = 0.2),
    line = list(
      color = "transparent"
    ),
    showlegend = TRUE,
    legendgroup = 'acceleration_band',
    name = paste0(
      "Acceleration Bands"
    )
  )

  .plotting_environment$main
}
