#' @name NVDA
#' @title NVIDIA Corporation (NVDA)
#'
#' @description
#' Daily OHLCV price data for NVIDIA Corporation (NVDA), covering
#' 2022-01-01 to 2023-12-31. Includes a period of high volatility
#' useful for testing momentum and trend-following indicators.
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
#' data(NVDA, package = "talib")
#'
#' ## Compute MACD on NVDA
#' talib::moving_average_convergence_divergence(NVDA)
"NVDA"
