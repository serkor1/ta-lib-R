#' @name ATOM
#' @title Cosmos (ATOM)
#'
#' @description
#' Daily OHLCV price data for Cosmos (ATOM), denominated in USDC,
#' covering 2022-01-01 to 2022-12-31. Includes a full bear-market
#' cycle useful for testing candlestick pattern recognition on
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
#' data(ATOM, package = "talib")
#'
#' ## Scan for Doji patterns on ATOM
#' talib::doji(ATOM)
"ATOM"
