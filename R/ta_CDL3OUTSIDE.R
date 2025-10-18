#' @export
#' @family Pattern Recognition
#'
#' @title Three Outside
#'
#' @templateVar .title Three Outside
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun three_outside
#'
#' @template description
#'
#' @returns
#' \describe{
#'  \item{three_outside}{1 for bullish, -1 for bearish and 0 for no pattern}
#' }
three_outside <- function(
	x,
	cols,
	...
) {
	UseMethod(
		"three_outside"
	)
}

#' @export
#'
#' @usage NULL
#'
#' @rdname three_outside
#' @aliases three_outside
CDL3OUTSIDE <- three_outside

#' @usage NULL
#' @aliases three_outside
#' @export
three_outside.default <- function(
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
			"impl_ta_CDL3OUTSIDE",
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
	colnames(x) <- "three_outside"

	## return value
	return(x)
}

#' @usage NULL
#' @aliases three_outside
#' @export
three_outside.data.frame <- function(
	x,
	cols,
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases three_outside
#' @export
three_outside.matrix <- function(
	x,
	cols,
	...
) {
	as.matrix(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases three_outside
#' @export
three_outside.plotly <- function(
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
	.indicator <- three_outside.default(
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
		pattern_name = "Three Outside",
		agnostic = FALSE
	)

	.plotting_environment$main
}
