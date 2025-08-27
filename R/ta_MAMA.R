#' @title Mesa Adaptive Moving Average (MAMA)
#'
#' @family Overlap Study
#' @export
MAMA <- function(x, n = 10, ...) {
  UseMethod("MAMA")
}

#' @rdname MAMA
#' @usage NULL
#' @export
MAMA.default <- function(x, n = 10, ...) {
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
    7L
  )
}

#' @rdname MAMA
#' @usage NULL
#' @export
MAMA.plotly <- function(x, n = 10, ...) {
  dots <- list(...)
  series <- dots$.series

  mama <- .Call(
    "impl_ta_MA",
    .univariate_series(series),
    as.integer(n),
    7L
  )

  df <- data.frame(
    idx = seq_along(mama),
    mama = as.numeric(mama)
  )

  .plotting_environment$main <- plotly::add_trace(
    x,
    data = df, # bind data here (creates/sets cur_data)
    x = ~idx,
    y = ~mama, # refer to columns, not objects in caller env
    type = "scatter",
    mode = "lines",
    name = sprintf("MAMA(%d)", n),
    inherit = FALSE,
    xaxis = "x",
    yaxis = "y" # ensure it lands on the main panel
  )

  .plotting_environment$main
}
