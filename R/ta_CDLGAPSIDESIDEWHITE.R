#' @export
#' @family Pattern Recognition
#'
#' @title Up/Down-gap side-by-side white lines
#'
#' @templateVar .title Up/Down-gap side-by-side white lines
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun gaps_side_white
#'
#' @template description
#'
#' @returns
#' \describe{
#'  \item{gaps_side_white}{1 for bullish, -1 for bearish and 0 for no pattern}
#' }
gaps_side_white <- function(
	x,
	cols,
	...
) {
	UseMethod(
		"gaps_side_white"
	)
}

#' @usage NULL
#' @aliases gaps_side_white
#' @export
CDLGAPSIDESIDEWHITE <- gaps_side_white

#' @usage NULL
#' @aliases gaps_side_white
#' @export
gaps_side_white.default <- function(
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
			"impl_ta_CDLGAPSIDESIDEWHITE",
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
	colnames(x) <- "gaps_side_white"

	## return value
	return(x)
}

#' @usage NULL
#' @aliases gaps_side_white
#' @export
gaps_side_white.data.frame <- function(
	x,
	cols,
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases gaps_side_white
#' @export
gaps_side_white.matrix <- function(
	x,
	cols,
	...
) {
	as.matrix(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases gaps_side_white
#' @export
gaps_side_white.plotly <- function(
	x,
	cols,
	...
) {
	## prepare OHLC series
	OHLC <- series(
		x = x,
		formula = cols,
		default = ~ open + high + low + close,
		...
	)

	## calculate pattern
	## indicators
	.indicator <- gaps_side_white.default(
		x = OHLC,
		cols = ~ open + high + low + close
	)

	.indicator$idx <- 1:nrow(.indicator)

	## chart patterns
	.plotting_environment$main <- pattern(
		p = .plotting_environment$main,
		x = .indicator,
		high = OHLC[[2]],
		low = OHLC[[3]],
		pattern_name = "Gaps-side White"
	)

	.plotting_environment$main
}
