#' @title Exponential Moving Average (EMA)
#' @family Overlap Study
#'
#' @templateVar .FUN DEMA
#' @template univariate_example
#'
#' @export
EMA <- function(x, n = 10, ...) {
  UseMethod(
    "EMA"
  )
}

#' @rdname EMA
#' @usage NULL
#' @export
EMA.default <- function(x, n = 10, ...) {
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
  assert(is.numeric(x))
  assert(n >= 2)

  ## 1) pass `x` to C
  .Call(
    "impl_ta_MA",
    x,
    as.integer(n),
    1L
  )
}

#' @rdname EMA
#' @usage NULL
#' @export
EMA.plotly <- function(x, n = 10, ...) {
  dots <- list(...)
  series <- dots$.series

  ema <- .Call(
    "impl_ta_MA",
    .univariate_series(series),
    as.integer(n),
    1L
  )

  df <- data.frame(
    idx = seq_along(ema),
    ema = as.numeric(ema)
  )

  .plotting_environment$main <- plotly::add_trace(
    x,
    data = df, # bind data here (creates/sets cur_data)
    x = ~idx,
    y = ~ema, # refer to columns, not objects in caller env
    type = "scatter",
    mode = "lines",
    name = sprintf("EMA(%d)", n),
    inherit = FALSE,
    xaxis = "x",
    yaxis = "y" # ensure it lands on the main panel
  )

  .plotting_environment$main
}
