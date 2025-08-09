#' @title Moving Average Convergence Divergence
#' @export
moving_average_convergence_divergence <- function(
  x, 
  fast = 12, 
  slow = 26, 
  signal = 9, 
  ...) {

    UseMethod("moving_average_convergence_divergence")

}

#' @export
moving_average_convergence_divergence.default <- function(
  x, 
  fast = 12, 
  slow = 26, 
  signal = 9, 
  ...) {
    
  if (!is.null(dim(x)) && !is.numeric(x)) {
    stop("`x` has to be a double vector", call. = FALSE)
  }

  ## ) check args
  ##   for calls
  env   <- parent.frame()
  exprs <- substitute(list(fast = fast, slow = slow, signal = signal))[-1L]
  is_calls <- vapply(exprs, .is_ma_spec, logical(1L), env = env)

  if (!(all(is_calls) || all(!is_calls))) {
    stop("Either all of `fast`, `slow` and `signal` is specified as calls, or none at all. See examples for more details.")
  }

  if (!all(is_calls)) {
    fast_i   <- .eval_int(exprs$fast,   env)
    slow_i   <- .eval_int(exprs$slow,   env)
    signal_i <- .eval_int(exprs$signal, env)

    if (fast_i == 12L && slow_i == 26L) {
      return(.Call("impl_ta_MACDFIX", x, signal_i))
    }

    return(.Call("impl_ta_MACD", x, fast_i, slow_i, signal_i))
  }

  fast_call <- .normalize_ma_arg_expr(exprs$fast, env)
  slow_call <- .normalize_ma_arg_expr(exprs$slow, env)
  signal_call <- .normalize_ma_arg_expr(exprs$signal, env)

  fast_ma   <- map_maType_call(fast_call)
  slow_ma   <- map_maType_call(slow_call)
  signal_ma <- map_maType_call(signal_call)

  .Call(
    "impl_ta_MACDEXT",
    x,
    fast_ma$n, 
    fast_ma$maType,
    slow_ma$n,   
    slow_ma$maType,
    signal_ma$n, 
    signal_ma$maType
  )
}

#' @export
MACD <- function(
  x, 
  fast = 12, 
  slow = 26, 
  signal = 9, 
  ...) {
    moving_average_convergence_divergence(
      x,
      fast   = substitute(fast),
      slow   = substitute(slow),
      signal = substitute(signal),
      ...
    )
}
