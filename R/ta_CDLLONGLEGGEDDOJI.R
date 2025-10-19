#' @export
#' @family Pattern Recognition
#'
#' @title Long Legged Doji
#'
#' @templateVar .title Long Legged Doji
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun long_legged_doji
#'
#' @template description
#'
#' @returns
#' \describe{
#'  \item{long_legged_doji}{1 for bullish, -1 for bearish and 0 for no pattern}
#' }
long_legged_doji <- function(x, cols, ...) {
	UseMethod("long_legged_doji")
}

#' @export
#' @usage NULL
#' @rdname long_legged_doji
#' @aliases long_legged_doji
CDLLONGLEGGEDDOJI <- long_legged_doji

#' @usage NULL
#' @aliases long_legged_doji
#' @export
long_legged_doji.default <- function(x, cols, ...) {
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
		"impl_ta_CDLLONGLEGGEDDOJI",
		OHLC[[1]],
		OHLC[[2]],
		OHLC[[3]],
		OHLC[[4]],
		as.logical(getOption("talib.normalize", TRUE))
	))
	colnames(x) <- "long_legged_doji"
	return(x)
}

#' @usage NULL
#' @aliases long_legged_doji
#' @export
long_legged_doji.data.frame <- function(x, cols, ...) {
	as.data.frame(NextMethod())
}

#' @usage NULL
#' @aliases long_legged_doji
#' @export
long_legged_doji.matrix <- function(x, cols, ...) {
	as.matrix(NextMethod())
}

#' @usage NULL
#' @aliases long_legged_doji
#' @export
long_legged_doji.plotly <- function(x, cols, ...) {
	OHLC <- series(
		x = x,
		formula = cols,
		default = ~ open + high + low + close,
		...
	)
	.indicator <- long_legged_doji.default(
		x = OHLC,
		cols = ~ open + high + low + close
	)

	## add x-axis conditional on whether
	## the data have been subsetted or not
	.indicator$idx <- add_idx(
		OHLC
	)

	.plotting_environment$main <- pattern(
		p = .plotting_environment$main,
		x = .indicator,
		high = OHLC[[2]],
		low = OHLC[[3]],
		pattern_name = "long_legged_doji"
	)
	.plotting_environment$main
}
