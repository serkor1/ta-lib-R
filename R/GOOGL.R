#' @name GOOGL
#' @title Alphabet Inc. (GOOGL)
#'
#' @description
#' Daily OHLCV price data for Alphabet Inc. (GOOGL), denominated in
#' USD, covering 2019-01-01 to 2021-12-31. Stored as an `xts` object
#' with a `Date` index and quantmod-style prefixed column names - the
#' exact shape returned by `quantmod::getSymbols()` - and used by the
#' unit tests for the `xts` methods.
#'
#' @format An `xts` object with 756 rows and 6 columns.
#'
#' \describe{
#'  \item{GOOGL.Open}{Opening price for the trading day.}
#'  \item{GOOGL.High}{Highest price reached during the trading day.}
#'  \item{GOOGL.Low}{Lowest price reached during the trading day.}
#'  \item{GOOGL.Close}{Closing price for the trading day.}
#'  \item{GOOGL.Volume}{Total trading volume for the day.}
#'  \item{GOOGL.Adjusted}{Adjusted closing price for the trading day.}
#' }
#'
#' @source Loaded using [quantmod](https://cran.r-project.org/web/packages/quantmod/index.html).
#'
#' @concept Financial Data
#' @concept OHLCV
#'
#' @docType data
#' @keywords datasets
#'
#' @examples
#' ## Load the dataset
#' data(GOOGL, package = "talib")
#'
#' ## Scan for Doji patterns on GOOGL
#' talib::doji(GOOGL)
"GOOGL"
