#' @title Doji Star
#' @family Pattern Recognition
#' @export
doji_star <- function(x, ...) {
	UseMethod(
		"doji_star"
	)
}

#' @export
CDLDOJISTAR <- doji_star

#' @export
doji_star.default <- function(x, ...) {
	.Call(
		"impl_ta_CDLDOJISTAR",
		.open(x),
		.high(x),
		.low(x),
		.close(x),
		as.logical(getOption("talib.normalize", TRUE))
	)
}
