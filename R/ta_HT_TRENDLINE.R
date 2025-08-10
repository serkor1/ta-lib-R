
#' @title Hilbert Transform - Instantaneous Trendline
#' @export
ht_trendline <- function(x, ...) {
    UseMethod("ht_trendline")
}

#' @export
ht_trendline.default <- function(x, ...) {
    .Call(
        "impl_ta_HT_TRENDLINE",
        as.numeric(x)
    )
}