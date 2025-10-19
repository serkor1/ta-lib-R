#' @export
#' @family Pattern Recognition
#'
#' @title Unique Three River
#'
#' @templateVar .title Unique Three River
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun unique_3_river
#'
#' @template description
#'
#' @returns
#' \describe{
#'  \item{unique_3_river}{1 for bullish reversal, 0 for no pattern}
#' }
unique_3_river <- function(x, cols, ...) UseMethod("unique_3_river")

#' @export
#' @usage NULL
#' @rdname unique_3_river
#' @aliases unique_3_river
CDLUNIQUE3RIVER <- unique_3_river

#' @export
unique_3_river.default <- function(x, cols, ...) {
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
		"impl_ta_CDLUNIQUE3RIVER",
		OHLC[[1]],
		OHLC[[2]],
		OHLC[[3]],
		OHLC[[4]],
		as.logical(getOption("talib.normalize", TRUE))
	))
	colnames(x) <- "unique_3_river"
	x
}

#' @export
unique_3_river.data.frame <- function(x, cols, ...) as.data.frame(NextMethod())
#' @export
unique_3_river.matrix <- function(x, cols, ...) as.matrix(NextMethod())
#' @export
unique_3_river.plotly <- function(x, cols, ...) {
	OHLC <- series(
		x = x,
		formula = cols,
		default = ~ open + high + low + close,
		...
	)
	.indicator <- unique_3_river.default(
		x = OHLC,
		cols = ~ open + high + low + close
	)

	## add x-axis conditional on whether
	## the data have been subsetted or not
	.indicator$idx <- add_idx(
		OHLC
	)

	.plotting_environment$main <- pattern(
		.plotting_environment$main,
		.indicator,
		OHLC[[2]],
		OHLC[[3]],
		"unique_3_river"
	)
	.plotting_environment$main
}
