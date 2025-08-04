#' @title Commodity Channel Index
#'
#' @description
#'
#'
#' @author Serkan Korkmaz
#'
#' @export
commodity_channel_index <- function(x, lag) {
    .Call("c_commodity_channel_index", x[,2], x[,3], x[,4], as.integer(lag))
}