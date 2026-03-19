#' @name ATOM
#' @title Cosmos (ATOM)
#'
#' @description
#' USDC denominated Cosmos (ATOM) in daily intervals between
#' 2022-01-01 and 2022-12-31.
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
#' data(ATOM, package = "talib")
"ATOM"
