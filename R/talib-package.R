## usethis namespace: start
#' @useDynLib talib, .registration = TRUE, .fixes = "C_"
## usethis namespace: end
NULL

#' @title Generic function documentation
#' @name generic_documentation
#'
#' @description
#' A generic documentation block for documenting parameters that
#' are common across all functions. Avoids documenting parameters
#' that doesn't exist downstream.
#'
#' @param x An OHLC-V series coercible to [data.frame]. Columns must be named
#'   in lowercase (`open`, `high`, `low`, `close`, `volume`); column order
#'   does not matter.
#' @param cols ([formula]). An optional [formula] selecting columns from `x`
#'   via [model.frame] (e.g., `cols = ~close` or `cols = ~high + low`). For
#'   indicators based on a single column (e.g., Bollinger Bands, moving
#'   averages) each variable in `cols` is calculated independently; for
#'   indicators based on multiple columns (e.g., Stochastic) the selected
#'   columns replace the defaults used in the calculation.
#'   See `vignette("talib")` for details.
#' @param n ([integer]). Lookback period (window size). A positive [integer]
#'   of [length] 1.
#' @param eps ([double]). Penetration threshold for candlestick pattern
#'   recognition, expressed as a fraction of the candle body. A [double] of
#'   [length] 1.
#' @param na.ignore ([logical]). A [logical] of [length] 1. [FALSE] by default. If [TRUE], `NA`s in the input are stripped before calculation and re-inserted at their original positions in the output.
#' @param ... Additional parameters passed into [model.frame]
#'
#' @returns NULL
#' @keywords internal
#' @usage NULL
NULL

## roxygen documentation
## functions
generate_returns_section <- function(x) {
	## the function takes an object
	## created from talib::foo(talib::BTC) and
	## converts the resulting data.fram to
	##
	## \describe{
	##    \item{column_names}{type}
	## }
	##

	## 1) extract column names
	##    'as is'
	column_names <- colnames(x)

	## 2) extract 'typeof' instead
	##    of 'class' to get the C-compatible
	##    type
	type <- vapply(
		X = x,
		FUN = function(col) {
			paste(typeof(col), collapse = "/")
		},
		FUN.VALUE = character(1)
	)

	## 3) construct the items as
	##    \item{column_names}{type}
	items <- paste0(
		"\\item{",
		column_names,
		"}",
		"{[",
		type,
		"]}"
	)

	## 4) return as:
	##    \describe{
	##    	\item{column_names}{type}
	##    }
	##
	paste0(
		"\\describe{\n",
		paste(items, collapse = "\n"),
		"\n}"
	)
}
