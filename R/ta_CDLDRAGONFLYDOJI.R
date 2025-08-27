#' @title Dragonfly Doji
#' @family Pattern Recognition
#' @export
dragonfly_doji <- function(x, ...) {
  UseMethod(
    "dragonfly_doji"
  )
}

#' @export
CDLDRAGONFLYDOJI <- dragonfly_doji

#' @export
dragonfly_doji.default <- function(x, ...) {
  .Call(
    "impl_ta_CDLDRAGONFLYDOJI",
    .open(x),
    .high(x),
    .low(x),
    .close(x),
    as.logical(getOption("talib.normalize", TRUE))
  )
}
