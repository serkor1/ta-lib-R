#' @export
#' @family Pattern Recognition
#'
#' @title Upside/Downside Gap Three Methods
#'
#' @templateVar .title Upside/Downside Gap Three Methods
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun xside_gap_3_methods
#'
#' @template description
#'
#' @returns
#' \describe{
#'  \item{xside_gap_3_methods}{1 for bullish continuation, -1 for bearish continuation, 0 for no pattern}
#' }
xside_gap_3_methods <- function(
	x,
	cols,
	...
) {
	UseMethod("xside_gap_3_methods")
}

#' @export
#' @usage NULL
#' @rdname xside_gap_3_methods
#' @aliases xside_gap_3_methods
CDLXSIDEGAP3METHODS <- xside_gap_3_methods

#' @usage NULL
#' @aliases xside_gap_3_methods
#' @export
xside_gap_3_methods.default <- function(
	x,
	cols,
	...
) {
	if (!missing(cols)) {
		assert(
			is.formula(cols),
			paste0(
				"'cols' has to be <",
				class(~s),
				">. Got <",
				class(cols),
				">."
			)
		)
		assert(
			length(all.vars(cols)) == 4,
			paste0(
				"'cols' has to be length 4. Got length ",
				length(all.vars(cols))
			)
		)
	}

	OHLC <- series(
		x = cols,
		default = ~ open + high + low + close,
		data = x,
		...
	)

	x <- as.data.frame(.Call(
		"impl_ta_CDLXSIDEGAP3METHODS",
		OHLC[[1]],
		OHLC[[2]],
		OHLC[[3]],
		OHLC[[4]],
		as.logical(getOption("talib.normalize", TRUE))
	))

	colnames(x) <- "xside_gap_3_methods"
	return(x)
}

#' @usage NULL
#' @aliases xside_gap_3_methods
#' @export
xside_gap_3_methods.data.frame <- function(x, cols, ...) {
	as.data.frame(NextMethod())
}

#' @usage NULL
#' @aliases xside_gap_3_methods
#' @export
xside_gap_3_methods.matrix <- function(x, cols, ...) {
	as.matrix(NextMethod())
}

#' @usage NULL
#' @aliases xside_gap_3_methods
#' @export
xside_gap_3_methods.plotly <- function(x, cols, ...) {
	OHLC <- series(
		x = x,
		formula = cols,
		default = ~ open + high + low + close,
		...
	)
	.indicator <- xside_gap_3_methods.default(
		x = OHLC,
		cols = ~ open + high + low + close
	)
	.indicator$idx <- 1:nrow(.indicator)
	.plotting_environment$main <- pattern(
		p = .plotting_environment$main,
		x = .indicator,
		high = OHLC[[2]],
		low = OHLC[[3]],
		pattern_name = "xside_gap_3_methods"
	)
	.plotting_environment$main
}
