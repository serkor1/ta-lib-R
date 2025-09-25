#' @export
#' @family Pattern Recognition
#'
#' @title Closing Marubozu
#'
#' @templateVar .title Closing Marubozu
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun closing_marubozu
#'
#' @template description
#'
#' @returns
#' \describe{
#'  \item{closing_marubozu}{1 for bullish, -1 for bearish and 0 for no pattern}
#' }
closing_marubozu <- function(
	x,
	cols,
	...
) {
	UseMethod(
		"closing_marubozu"
	)
}

#' @usage NULL
#' @aliases closing_marubozu
#' @export
CDLCOUNTERATTACK <- closing_marubozu

#' @usage NULL
#' @aliases closing_marubozu
#' @export
closing_marubozu.default <- function(
	x,
	cols,
	...
) {
	## validate input
	## asssuming everyting
	## is numerical values
	if (!missing(cols)) {
		## check if formula
		assert(
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
			"impl_ta_CDLCLOSINGMARUBOZU",
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
	colnames(x) <- "closing_marubozu"

	## return value
	return(x)
}

#' @usage NULL
#' @aliases closing_marubozu
#' @export
closing_marubozu.data.frame <- function(
	x,
	cols,
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases closing_marubozu
#' @export
closing_marubozu.matrix <- function(
	x,
	cols,
	...
) {
	as.matrix(
		NextMethod()
	)
}
