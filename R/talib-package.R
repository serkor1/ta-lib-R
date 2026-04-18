## usethis namespace: start
#' @useDynLib talib, .registration = TRUE, .fixes = "C_"
## usethis namespace: end
NULL

## generic_documentation was previously an internal Rd page used as the
## target of `@inheritParams generic_documentation` in the indicator
## templates. It has been inlined: the shared parameters (n, eps,
## na.ignore, ...) are now declared directly in
## man-roxygen/description.R and man-roxygen/rolling_description.R,
## removing the need for an internal cross-reference target.

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
