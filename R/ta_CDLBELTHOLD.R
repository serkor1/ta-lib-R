#' @export
#' @family Pattern Recognition
#'
#' @title Belt Hold
#'
#' @templateVar .title Belt Hold
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun belt_hold
#'
#' @template description
#'
#' @returns
#' \describe{
#'  \item{belt_hold}{1 for bullish, -1 for bearish and 0 for no pattern}
#' }
belt_hold <- function(
	x,
	cols,
	...
) {
	UseMethod(
		"belt_hold"
	)
}

#' @export
#'
#' @usage NULL
#'
#' @rdname belt_hold
#' @aliases belt_hold
CDLBELTHOLD <- belt_hold

#' @usage NULL
#' @aliases belt_hold
#' @export
belt_hold.default <- function(
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
			"impl_ta_CDLBELTHOLD",
			OHLC[[1]],
			OHLC[[2]],
			OHLC[[3]],
			OHLC[[4]],
			as.logical(
				getOption("talib.normalize", TRUE)
			)
		)
	)

	## set column names
	colnames(x) <- "belt_hold"

	## return value
	return(x)
}

#' @usage NULL
#' @aliases belt_hold
#' @export
belt_hold.data.frame <- function(
	x,
	cols,
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases belt_hold
#' @export
belt_hold.matrix <- function(
	x,
	cols,
	...
) {
	as.matrix(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases belt_hold
#' @export
belt_hold.plotly <- function(
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
	.indicator <- belt_hold.default(
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
		pattern_name = "Belt Hold"
	)

	.plotting_environment$main
}
