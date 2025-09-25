#' @export
#' @family Pattern Recognition
#'
#' @title Concealing Baby Swallow
#'
#' @templateVar .title Concealing Baby Swallow
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun concealing_baby_swallow
#'
#' @template description
#'
#' @returns
#' \describe{
#'  \item{concealing_baby_swallow}{1 for bullish, -1 for bearish and 0 for no pattern}
#' }
concealing_baby_swallow <- function(
	x,
	cols,
	...
) {
	UseMethod(
		"concealing_baby_swallow"
	)
}

#' @usage NULL
#' @aliases concealing_baby_swallow
#' @export
CDLBABYSWALL <- concealing_baby_swallow

#' @usage NULL
#' @aliases concealing_baby_swallow
#' @export
concealing_baby_swallow.default <- function(
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
			"impl_ta_CDLBABYSWALL",
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
	colnames(x) <- "concealing_baby_swallow"

	## return value
	return(x)
}

#' @usage NULL
#' @aliases concealing_baby_swallow
#' @export
concealing_baby_swallow.data.frame <- function(
	x,
	cols,
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases concealing_baby_swallow
#' @export
concealing_baby_swallow.matrix <- function(
	x,
	cols,
	...
) {
	as.matrix(
		NextMethod()
	)
}
