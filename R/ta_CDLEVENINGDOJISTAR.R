#' @export
#' @family Pattern Recognition
#'
#' @title Evening Doji Star
#'
#' @templateVar .title Evening Doji Star
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun evening_doji_star
#'
#' @template description
#'
#' @returns
#' \describe{
#'  \item{evening_doji_star}{1 for bullish, -1 for bearish and 0 for no pattern}
#' }
evening_doji_star <- function(
	x,
	cols,
	penetration = 0.1,
	...
) {
	UseMethod(
		"evening_doji_star"
	)
}

#' @usage NULL
#' @aliases evening_doji_star
#' @export
CDLEVENINGDOJISTAR <- evening_doji_star

#' @usage NULL
#' @aliases evening_doji_star
#' @export
evening_doji_star.default <- function(
	x,
	cols,
	penetration = 0.1,
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
			"impl_ta_CDLEVENINGDOJISTAR",
			x[[1]],
			x[[2]],
			x[[3]],
			x[[4]],
			penetration,
			as.logical(
				getOption("talib.normalize", TRUE)
			)
		)
	)

	## set column names
	colnames(x) <- "evening_doji_star"

	## return value
	return(x)
}

#' @usage NULL
#' @aliases evening_doji_star
#' @export
evening_doji_star.data.frame <- function(
	x,
	cols,
	penetration = 0.1,
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases evening_doji_star
#' @export
evening_doji_star.matrix <- function(
	x,
	cols,
	penetration = 0.1,
	...
) {
	as.matrix(
		NextMethod()
	)
}
