#' @name BTC
#' @title Bitcoin (BTC)
#'
#' @description
#' USDC denominated Bitcoin (BTC) in daily intervals between
#' 2024-01-01 and 2024-12-31.
#'
#' @format A [data.frame] with 366 rows and 5 columns.
#'
#' \describe{
#'  \item{open}{Candle opening price.}
#'  \item{high}{Candle highest price.}
#'  \item{low}{Candle lowest price.}
#'  \item{close}{Candle closing price.}
#'  \item{volume}{Candle volume.}
#' }
#'
#' @references Loaded using [cryptoQuotes](https://cran.r-project.org/web//packages/cryptoQuotes/index.html)
#'
#' @docType data
#' @keywords datasets
#'
#' @examples
#' ## Load the dataset
#' data(BTC, package = "talib")
data(BTC, package = "talib")
