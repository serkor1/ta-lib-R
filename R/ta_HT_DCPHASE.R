#' @title Hilbert Transform - Dominant Cycle Phase
#' @family Cycle Indicator
#' @export
ht_dcphase <- function(x, ...) {
    UseMethod("ht_dcphase")
}

#' @export
ht_dcphase.default <- function(x, ...) {
    .Call(
        "impl_ta_HT_DCPHASE",
        as.numeric(x)
    )
}
