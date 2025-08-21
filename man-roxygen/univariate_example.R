#' @examples
#' ## calculate values
#' result <- talib::<%= .FUN %>(
#'      x = talib::BTC[,1L]
#' )
#'
#' tail(result)
#'
#' ## charting the indicator
#' {
#'  ## main chart
#'  talib::chart(talib::BTC)
#'
#'  ## indicator
#'  talib::indicator(
#'   .f   = talib::<%= .FUN %>(),
#'   .var = ~close
#'  )
#' }

