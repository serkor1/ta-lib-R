#' @export
#' @family Pattern Recognition
#'
#' @title Harami Cross
#'
#' @templateVar .title Harami Cross
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun harami_cross
#'
#' @template description
#'
#' @returns
#' \describe{
#'  \item{harami_cross}{1 for bullish, -1 for bearish and 0 for no pattern}
#' }
harami_cross <- function(
	x,
	cols,
	...
) {
	UseMethod(
		"harami_cross"
	)
}

#' @export
#'
#' @usage NULL
#'
#' @rdname harami_cross
#' @aliases harami_cross
CDLHARAMICROSS <- harami_cross

#' @usage NULL
#' @aliases harami_cross
#' @export
harami_cross.default <- function(
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
			"impl_ta_CDLHARAMICROSS",
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
	colnames(x) <- "harami_cross"

	## return value
	return(x)
}

#' @usage NULL
#' @aliases harami_cross
#' @export
harami_cross.data.frame <- function(
	x,
	cols,
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases harami_cross
#' @export
harami_cross.matrix <- function(
	x,
	cols,
	...
) {
	as.matrix(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases harami_cross
#' @export
harami_cross.plotly <- function(
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
	.indicator <- harami_cross.default(
		x = OHLC,
		cols = ~ open + high + low + close
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
		pattern_name = "harami_cross"
	)

	.plotting_environment$main
}
