#' @export
#' @family Pattern Recognition
#'
#' @title Three-Line Strike
#'
#' @templateVar .title Three-Line Strike
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun three_line_strike
#'
#' @template description
#'
#' @returns
#' \describe{
#'  \item{three_line_strike}{1 for bullish, -1 for bearish and 0 for no pattern}
#' }
three_line_strike <- function(
	x,
	cols,
	...
) {
	UseMethod(
		"three_line_strike"
	)
}

#' @usage NULL
#' @aliases three_line_strike
#' @export
CDL3LINESTRIKE <- three_line_strike

#' @usage NULL
#' @aliases three_line_strike
#' @export
three_line_strike.default <- function(
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
			"impl_ta_CDL3LINESTRIKE",
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
	colnames(x) <- "three_line_strike"

	## return value
	return(x)
}

#' @usage NULL
#' @aliases three_line_strike
#' @export
three_line_strike.data.frame <- function(
	x,
	cols,
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases three_line_strike
#' @export
three_line_strike.matrix <- function(
	x,
	cols,
	...
) {
	as.matrix(
		NextMethod()
	)
}
