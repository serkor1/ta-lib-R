#' @title Stochastic
#'
#' @family Momentum Indicator
#' @export
stochastic <- function(x, fastk, slowk = SMA(n = 10), slowd = SMA(n = 8), ...) {
  UseMethod(
    "stochastic"
  )
}

#' @export
stochastic.default <- function(
  x,
  fastk,
  slowk = SMA(n = 10),
  slowd = SMA(n = 8),
  ...
) {
  slowk_ma <- map_maType_call(substitute(slowk))
  slowd_ma <- map_maType_call(substitute(slowd))

  .Call(
    "impl_ta_STOCH",
    .high(x),
    .low(x),
    .close(x),
    as.integer(fastk), # 4. optInFastK_Period
    as.integer(slowk_ma$n), # 5. optInSlowK_Period
    as.integer(slowk_ma$maType), # 6. optInSlowK_MAType
    as.integer(slowd_ma$n), # 7. optInSlowD_Period
    as.integer(slowd_ma$maType) # 8. optInSlowD_MAType
  )
}
