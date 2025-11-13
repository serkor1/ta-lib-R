## usethis namespace: start
#' @useDynLib talib, .registration = TRUE
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
#' @param x An OHLC-V series that is coercible to [data.frame]. The function assumes that all columns are named in lowercase and order invariant.
#' @param cols ([formula]). An optional [formula] passed into [model.frame]. If passed into indicators based on univariate series, the function calculates indicators for each element in 'cols'. For indicators based on multivariate series, it will alter the calculation itself. See `vignette("talib")` for more details.
#' @param n ([integer]). An [integer] of [length] 1.
#' @param eps ([double]). A [double] of [length] 1. Percentage of penetration of a candle within another candle.
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
