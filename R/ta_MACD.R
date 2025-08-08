#' @title NULL
#' @usage NULL
#' 
#' @template description
#'
#' @templateVar .title Moving Average Convergence/Divergence
#' @templateVar .type multivariate
#' @templateVar .fun moving_average_convergence_divergence
#' @templateVar .author Serkan Korkmaz
#'
#' @returns Something
#' @export
moving_average_convergence_divergence <- function(
  x, 
  fast = 12, 
  slow = 26, 
  signal = 9, 
  ...) {

  UseMethod(
    generic = "moving_average_convergence_divergence"
    )
}

#' @export
moving_average_convergence_divergence.default <- function(
  x, 
  fast = 12, 
  slow = 26, 
  signal = 9,
  ...) {

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
    assert(is.numeric(x));

    if (is.number(fast) && is.number(slow) && is.number(signal)) {
      if (fast == 12 & slow == 26) {
        
        return (
          .Call(
        "impl_ta_MACDFIX",
        x,
        as.integer(signal)
      )
        )
      
    } else {
      
      return(
.Call(
        "impl_ta_MACD", 
        x, 
        as.integer(fast), 
        as.integer(slow), 
        as.integer(signal)
      )
      )
      
    }
    }

      fast_call   <- if (is.call(fast))   fast   else substitute(fast)
  slow_call   <- if (is.call(slow))   slow   else substitute(slow)
  signal_call <- if (is.call(signal)) signal else substitute(signal)

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
MACD <- function(x, 
fast = 12, 
  slow = 26, 
  signal = 9, 
  ...) {

    moving_average_convergence_divergence(
      x,
      fast,
      slow,
      signal
    )

}

#' @export
MACDFIX <- function(x, 
  signal = 9, 
  ...) {

    moving_average_convergence_divergence(
      x,
      12,
      26,
      signal
    )

}

#' @export
MACDEXT <- function(
  x,
  fast   = EMA(n = 12),
  slow   = EMA(n = 26),
  signal = EMA(n = 9),
  ...
) {
  moving_average_convergence_divergence(
    x,
    fast   = substitute(fast),
    slow   = substitute(slow),
    signal = substitute(signal),
    ...
  )
}
