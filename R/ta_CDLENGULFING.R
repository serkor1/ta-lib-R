#' @export
#' @family Pattern Recognition
#'
#' @title Engulfing
#'
#' @templateVar .title Engulfing
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun engulfing
#'
#' @template description
#'
#' @returns
#' \describe{
#'  \item{engulfing}{1 for bullish, -1 for bearish and 0 for no pattern}
#' }
engulfing <- function(
	x,
	cols,
	...
) {
	UseMethod(
		"engulfing"
	)
}

#' @export
#'
#' @usage NULL
#'
#' @rdname engulfing
#' @aliases engulfing
CDLENGULFING <- engulfing

#' @usage NULL
#' @aliases engulfing
#' @export
engulfing.default <- function(
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
			"impl_ta_CDLENGULFING",
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
	colnames(x) <- "engulfing"

	## return value
	return(x)
}

#' @usage NULL
#' @aliases engulfing
#' @export
engulfing.data.frame <- function(
	x,
	cols,
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases engulfing
#' @export
engulfing.matrix <- function(
	x,
	cols,
	...
) {
	as.matrix(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases engulfing
#' @export
engulfing.plotly <- function(
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
	.indicator <- engulfing.default(
		x = OHLC,
		cols = rebuild_formula(
			names(OHLC)
		)
	)

	## add x-axis conditional on whether
	## the data have been subsetted or not
	.indicator$idx <- add_idx(
		OHLC
	)

	## chart patterns
	.plotting_environment$main <- pattern(
		p = .plotting_environment$main,
		x = .indicator,
		high = OHLC[[2]],
		low = OHLC[[3]],
		pattern_name = "Engulfing",
		agnostic = FALSE
	)

	.plotting_environment$main
}
