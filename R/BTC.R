#' @name BTC
#' @title Bitcoin (BTC)
#'
#' @description
#' Daily OHLCV price data for Bitcoin (BTC), denominated in USDC,
#' covering 2024-01-01 to 2024-12-31. Useful for testing technical
#' analysis indicators and candlestick pattern recognition on
#' cryptocurrency data.
#'
#' @format A [data.frame] with 366 rows and 5 columns.
#'
#' \describe{
#'  \item{open}{Opening price for the trading day.}
#'  \item{high}{Highest price reached during the trading day.}
#'  \item{low}{Lowest price reached during the trading day.}
#'  \item{close}{Closing price for the trading day.}
#'  \item{volume}{Total trading volume for the day.}
#' }
#'
#' @source Loaded using [cryptoQuotes](https://cran.r-project.org/web//packages/cryptoQuotes/index.html).
#'
#' @concept Financial Data
#' @concept OHLCV
#'
#' @docType data
#' @keywords datasets
#'
#' @examples
#' ## Load the dataset
#' data(BTC, package = "talib")
#'
#' ## Compute RSI on Bitcoin closing prices
#' talib::relative_strength_index(BTC)
"BTC"
