#' @name SPY
#' @title SPDR S&P 500 ETF (SPY)
#'
#' @description
#' SPDR S&P 500 ETF (SPY) in daily intervals between
#' 2023-01-01 and 2024-12-31.
#'
#' @format A [matrix] with 501 rows and 5 columns.
#'
#' \describe{
#'  \item{open}{Candle opening price.}
#'  \item{high}{Candle highest price.}
#'  \item{low}{Candle lowest price.}
#'  \item{close}{Candle closing price.}
#'  \item{volume}{Candle volume.}
#' }
#'
#' @references Loaded using [quantmod](https://cran.r-project.org/web//packages//quantmod/index.html)
#'
#' @docType data
#' @keywords datasets
#'
#' @examples
#' ## Load the dataset
#' data(SPY, package = "talib")
data(SPY, package = "talib")
