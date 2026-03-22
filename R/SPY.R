#' @name SPY
#' @title SPDR S&P 500 ETF (SPY)
#'
#' @description
#' Daily OHLCV price data for the SPDR S&P 500 ETF (SPY), covering
#' 2023-01-01 to 2024-12-31. A widely used benchmark for U.S. equity
#' market performance and a common test case for technical analysis
#' strategies.
#'
#' @format A [matrix] with 501 rows and 5 columns.
#'
#' \describe{
#'  \item{open}{Opening price for the trading day.}
#'  \item{high}{Highest price reached during the trading day.}
#'  \item{low}{Lowest price reached during the trading day.}
#'  \item{close}{Closing price for the trading day.}
#'  \item{volume}{Total trading volume for the day.}
#' }
#'
#' @source Loaded using [quantmod](https://cran.r-project.org/web//packages//quantmod/index.html).
#'
#' @concept Financial Data
#' @concept OHLCV
#'
#' @docType data
#' @keywords datasets
#'
#' @examples
#' ## Load the dataset
#' data(SPY, package = "talib")
#'
#' ## Compute Bollinger Bands on SPY
#' talib::bollinger_bands(SPY)
"SPY"
