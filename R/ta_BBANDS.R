#' @title Bollinger Bands
#'
#' @family Overlap Study
#'
#' @export
bollinger_bands <- function(x, ma = SMA(n = 10), up = 2, down = 2, ...) {
  UseMethod(
    generic = "bollinger_bands"
  )
}

#' @export
BBANDS <- bollinger_bands

#' @export
bollinger_bands.default <- function(
  x,
  ma = SMA(n = 10),
  up = 2,
  down = 2,
  ...
) {
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
  assert(is.numeric(x))
  assert(ma$n >= 2)

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

#' @export
bollinger_bands.plotly <- function(
  x,
  ma = SMA(n = 10),
  up = 2,
  down = 2,
  ...
) {
  ma <- map_maType_call(substitute(ma))
  ## extract arguments
  ## from ellipsis
  dots <- list(...)
  series <- dots$.series

  ## extract chart objects
  .chart <- .plotting_environment$price_chart
  .value <- .Call(
    "impl_ta_BBANDS",
    series,
    ma$n,
    as.numeric(up),
    as.numeric(down),
    as.integer(ma$maType)
  )

  ## constuct chart
  ## element
  for (i in seq_len(ncol(.value))) {
    local({
      j <- i

      .plotting_environment$main <- plotly::add_lines(
        .plotting_environment$main,
        x = ~ seq_len(nrow(.value)),
        y = ~ .value[, j],
        inherit = FALSE,
        line = list(
          color = '#4682b4'
        ),
        showlegend = FALSE,
        legendgroup = 'bollinger_band',
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
    legendgroup = 'bollinger_band',
    name = paste0(
      "BBand"
    )
  )

  .plotting_environment$main
}
