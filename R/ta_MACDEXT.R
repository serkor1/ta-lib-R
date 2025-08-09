
#' @export
MACDEXT <- function(
  x,
  fast   = EMA(n = 12),
  slow   = EMA(n = 26),
  signal = EMA(n = 9),
  ...) {
    moving_average_convergence_divergence(
      x,
      fast   = substitute(fast),
      slow   = substitute(slow),
      signal = substitute(signal),
      ...
    )
}