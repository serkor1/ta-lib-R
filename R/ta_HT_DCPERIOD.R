#' @title Hilbert Transform - Dominant Cycle Period
#' @family Cycle Indicator
#' @export
ht_dcperiod <- function(x, ...) {
    UseMethod("ht_dcperiod")
}

#' @export
ht_dcperiod.default <- function(x, ...) {
    .Call(
        "impl_ta_HT_DCPERIOD",
        as.numeric(x)
    )
}
