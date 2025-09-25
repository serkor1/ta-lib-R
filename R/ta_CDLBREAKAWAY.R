#' @export
#' @family Pattern Recognition
#'
#' @title Break Away
#'
#' @templateVar .title Break Away
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun break_away
#'
#' @template description
#'
#' @returns
#' \describe{
#'  \item{break_away}{1 for bullish, -1 for bearish and 0 for no pattern}
#' }
break_away <- function(
	x,
	cols,
	...
) {
	UseMethod(
		"break_away"
	)
}

#' @usage NULL
#' @aliases break_away
#' @export
CDLBREAKAWAY <- break_away

#' @usage NULL
#' @aliases break_away
#' @export
break_away.default <- function(
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
			"impl_ta_CDLBREAKAWAY",
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
	colnames(x) <- "break_away"

	## return value
	return(x)
}

#' @usage NULL
#' @aliases break_away
#' @export
break_away.data.frame <- function(
	x,
	cols,
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases break_away
#' @export
break_away.matrix <- function(
	x,
	cols,
	...
) {
	as.matrix(
		NextMethod()
	)
}
