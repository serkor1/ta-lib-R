#' @title Hilbert Transform - SineWave
#' @export
ht_sine <- function(x, ...) {
    UseMethod("ht_sine")
}

#' @export
ht_sine.default <- function(x, ...) {
    .Call(
        "impl_ta_HT_SINE",
        as.numeric(x)
    )
}