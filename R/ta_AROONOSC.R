#' @title Aroon Oscillator
#'
#' @family Momentum Indicator
#'
#' @export
aroon_oscillator <- function(x, n, ...) {
	UseMethod(
		generic = "aroon_oscillator"
	)
}

#' @export
aroon_oscillator.default <- function(x, n, ...) {
	## default behaviour is to
	## coerce to a `matrix` check that
	## it is double and then pass to
	## C-side.

	## 0) validate input
	##    and stop the script
	##    if conditions are not
	##    met
	if (!is.matrix(x)) {
		x <- as.matrix(x)
	}
	assert(is.numeric(x))

	## 1) pass `x` assuming that
	##    it follows Open (x[,1]), High (x[,2])
	##    Low (x[,3]) and Close (x[,4])

	.Call("impl_ta_AROONOSC", .high(x), .low(x), as.integer(n))
}
