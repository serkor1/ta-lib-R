#' @title Simple Moving Average (SMA)
#'
#' @description
#' A short description...
#'
#' @param x A univariate series.
#' @param n An [integer] of [length] 1. The window size of the rolling average.
#' @param ... Parameters passed to and from other methods.
#'
#' @export
SMA <- function(x, n = 10, ...) {
  UseMethod(
    "SMA"
  )
}

#' @export
SMA.default <- function(x, n = 10, ...) {
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
    stop("`x` has to be a <double> vector")
  }
  assert(is.number(x))
  assert(n >= 2)

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
SMA.plotly <- function(x, n = 10, ...) {
  dots <- list(...)
  series <- dots$.series[, 1L]

  sma <- .Call(
    "impl_ta_MA",
    as.double(series),
    as.integer(n),
    0L
  )

  df <- data.frame(
    idx = seq_along(sma),
    sma = as.numeric(sma)
  )

  .plotting_environment$main <- plotly::add_trace(
    x,
    data = df, # bind data here (creates/sets cur_data)
    x = ~idx,
    y = ~sma, # refer to columns, not objects in caller env
    type = "scatter",
    mode = "lines",
    name = sprintf("SMA(%d)", n),
    inherit = FALSE,
    xaxis = "x",
    yaxis = "y" # ensure it lands on the main panel
  )

  .plotting_environment$main
}
