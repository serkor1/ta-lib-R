#' @details
#' General options for candlestick pattern recognition:
#'
#' \describe{
#' 		\item{N}{[integer]. Controls the number of candles to consider when identifying patterns.}
#' 		\item{alpha}{[double]. A sensitivity parameter when identifying patterns.}
#' }
#'
#' Available options and their defaults:
#' \describe{
#'		\item{BodyLong}{(N = 10, alpha = 1.0). Real body is long when it's longer than the average of the 10 previous candles' real body.}
#'		\item{BodyVeryLong}{(N = 10, alpha = 3.0). Real body is very long when it's longer than 3 times the average of the 10 previous candles' real body.}
#'		\item{BodyShort}{(N = 10, alpha = 1.0). Real body is short when it's shorter than the average of the 10 previous candles' real bodies.}
#'    \item{BodyDoji}{(N = 10, alpha = 0.1). Real body is like doji's body when it's shorter than 10% the average of the 10 previous candles' high-low range.}
#'		\item{ShadowLong}{(N = 0, alpha = 1.0). Shadow is long when it's longer than the real body.}
#'		\item{ShadowVeryLong}{(N = 0, alpha = 2.0). Shadow is very long when it's longer than 2 times the real body.}
#'		\item{ShadowShort}{(N = 0, alpha = 1.0). Shadow is short when it's shorter than half the average of the 10 previous candles' sum of shadows.}
#'		\item{ShadowVeryShort}{(N = 10, alpha = 0.1). Shadow is very short when it's shorter than 10% the average of the 10 previous candles' high-low range.}
#'		\item{Near}{(N = 5, alpha = 0.2). When measuring distance between parts of candles or width of gaps "near" means "<=20% of the average of the 5 previous candles high low range."}
#'		\item{Far}{(N = 5, alpha = 0.6). When measuring distance between parts of candles or width of gaps "far" means ">= 60% of the average of the 5 previous candles high-low range."}
#'		\item{Equal}{(N = 5, alpha = 0.05). When measuring distance between parts of candles or width of gaps "equal" means "<= 5% of the average of the 5 previous candles high-low range."}
#'}
#'
#' The options can be modified by running `options(talib.BodyLong.N = 5, talib.BodyLong.alpha = 0.2)`. See `vignette("candlestick")` for more details.
#'
