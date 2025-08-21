#' @title Hilbert Transform - Trend vs Cycle Mode
#' @family Cycle Indicator
#' @export
ht_trendmode <- function(x, ...) {
    UseMethod("ht_trendmode")
}

#' @export
ht_trendmode.default <- function(x, ...) {
    .Call(
        "impl_ta_HT_TRENDMODE",
        as.numeric(x)
    )
}
