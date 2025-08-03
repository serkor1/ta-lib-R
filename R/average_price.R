#' @title Average price
#' 
#' @description 
#' Calculate the average price
#'
#' 
#' @author Serkan Korkmaz
#' @export
average_price <- function(x) {

  m <- as.matrix(x)  
  if (!is.numeric(m)) stop("Input must be numeric or coercible to numeric matrix.")
  if (ncol(m) != 4L) {
    stop("Input must have 4 columns: Open, High, Low, Close.")
  }

  if (!is.null(colnames(m))) {
    cn <- tolower(colnames(m))
    wanted <- c("open", "high", "low", "close")
    if (all(wanted %in% cn)) {
      m <- m[, match(wanted, cn), drop = FALSE]
    } else {
    }
  }

  res <- .Call("c_average_price", m, PACKAGE = "talib")
  if (!is.numeric(res) || length(res) != nrow(m)) {
    stop("Unexpected result from native call.")
  }

  res
}