#' @title Simple Moving Average (SMA)
#'
#' @description
#' A short description...
#'
#' @param x A univariate series.
#' @param n An [integer] of [length] 1. The window size of the rolling average.
#' @param ... Parameters passed to and from other methods.
#'
#' @family Overlap Study
#'
#' @export
SMA <- function(
  x,
  n = 10,
  ...
) {
  UseMethod(
    "SMA"
  )
}

#' @export
SMA.numeric <- function(
  x,
  n = 10,
  ...
) {
  .Call(
    "impl_ta_MA",
    as.double(x),
    as.integer(n),
    0L
  )
}

#' @export
SMA.data.frame <- function(
  x,
  n = 10,
  cols,
  ...
) {
  ## extract series
  ## as and convert to list
  ## for vapply
  if (missing(cols)) {
    cols <- ~open
  }

  x <- series(
    x = cols,
    default = ~open,
    data = x,
    ...
  )
  ## calculate output
  ## using vapply
  x <- as.data.frame(vapply(
    as.list(x),
    FUN = function(x) {
      ## 1) pass `x` to C
      .Call(
        "impl_ta_MA",
        x,
        as.integer(n),
        0L
      )
    },
    FUN.VALUE = double(nrow(x)),
    USE.NAMES = TRUE
  ))

  colnames(x) <- paste0("sma_", colnames(x))

  x
}

#' @export
SMA.matrix <- function(
  x,
  n = 10,
  cols,
  ...
) {
  ## extract series
  ## as and convert to list
  ## for vapply
  if (missing(cols)) {
    cols <- ~open
  }

  x <- series(
    x = cols,
    default = ~open,
    data = x,
    ...
  )
  ## calculate output
  ## using vapply
  x <- as.matrix(vapply(
    as.list(x),
    FUN = function(x) {
      ## 1) pass `x` to C
      .Call(
        "impl_ta_MA",
        x,
        as.integer(n),
        0L
      )
    },
    FUN.VALUE = double(nrow(x)),
    USE.NAMES = TRUE
  ))

  colnames(x) <- paste0("sma_", colnames(x))

  x
}

#' @rdname SMA
#' @usage NULL
#' @export
SMA.plotly <- function(x, n = 10, ...) {
  dots <- list(...)
  series <- dots$.series

  sma <- .Call(
    "impl_ta_MA",
    .univariate_series(series),
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
