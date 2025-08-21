#' @title Hilbert Transform - Phasor Components
#' @family Cycle Indicator
#' @export
ht_phasor <- function(x, ...) {
    UseMethod("ht_phasor")
}

#' @export
ht_phasor.default <- function(x, ...) {
    .Call(
        "impl_ta_HT_PHASOR",
        as.numeric(x)
    )
}
