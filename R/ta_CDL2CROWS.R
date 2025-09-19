#' @export
#' @family Pattern Recognition
#'
#' @title Two Crows
#'
#' @templateVar .title Two Crows
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun two_crows
#'
#' @template description
#'
#' @returns
#' \describe{
#'  \item{two_crows}{1 for bullish, -1 for bearish and 0 for no pattern}
#' }
two_crows <- function(
	x,
	cols,
	...
) {
	UseMethod(
		"two_crows"
	)
}

#' @usage NULL
#' @aliases two_crows
#' @export
CDL2CROWS <- two_crows

#' @usage NULL
#' @aliases two_crows
#' @export
two_crows.default <- function(
	x,
	cols,
	...
) {
	## validate input
	## asssuming everyting
	## is numerical values
	if (!missing(cols)) {
		## check if formula
		asset(
			is.formula(cols),
			paste0(
				"'cols' has to be <",
				class(~s),
				">. ",
				"Got <",
				class(cols),
				">."
			)
		)

		## check if formula has the expected
		## length
		assert(
			length(all.vars(cols)) == 4,
			paste0(
				"'cols' has to be length 4. ",
				"Got length ",
				length(all.vars(cols))
			)
		)
	}

	## construct OHLC-series
	## from 'x'
	OHLC <- series(
		x = cols,
		default = ~ open + high + low + close,
		data = x,
		...
	)

	## construct data.frame
	## from source
	x <- as.data.frame(
		.Call(
			"impl_ta_CDL2CROWS",
			x[[1]],
			x[[2]],
			x[[3]],
			x[[4]],
			as.logical(
				getOption("talib.normalize", TRUE)
			)
		)
	)

	## set column names
	colnames(x) <- "two_crows"

	## return value
	return(x)
}

#' @usage NULL
#' @aliases two_crows
#' @export
two_crows.data.frame <- function(
	x,
	cols,
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases two_crows
#' @export
two_crows.matrix <- function(
	x,
	cols,
	...
) {
	as.matrix(
		NextMethod()
	)
}
