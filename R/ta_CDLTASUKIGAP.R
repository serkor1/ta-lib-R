#' @export
#' @family Pattern Recognition
#'
#' @title Tasuki Gap
#'
#' @templateVar .title Tasuki Gap
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun tasuki_gap
#'
#' @template description
#'
#' @returns
#' \describe{
#'  \item{tasuki_gap}{1 for bullish continuation, -1 for bearish continuation, 0 for no pattern}
#' }
tasuki_gap <- function(x, cols, ...) UseMethod("tasuki_gap")

#' @export
#' @usage NULL
#' @rdname tasuki_gap
#' @aliases tasuki_gap
CDLTASUKIGAP <- tasuki_gap

#' @export
tasuki_gap.default <- function(x, cols, ...) {
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
		"impl_ta_CDLTASUKIGAP",
		OHLC[[1]],
		OHLC[[2]],
		OHLC[[3]],
		OHLC[[4]],
		as.logical(getOption("talib.normalize", TRUE))
	))
	colnames(x) <- "tasuki_gap"
	x
}

#' @export
tasuki_gap.data.frame <- function(x, cols, ...) as.data.frame(NextMethod())
#' @export
tasuki_gap.matrix <- function(x, cols, ...) as.matrix(NextMethod())
#' @export
tasuki_gap.plotly <- function(x, cols, ...) {
	OHLC <- series(
		x = x,
		formula = cols,
		default = ~ open + high + low + close,
		...
	)
	.indicator <- tasuki_gap.default(
		x = OHLC,
		cols = ~ open + high + low + close
	)
	.indicator$idx <- 1:nrow(.indicator)
	.plotting_environment$main <- pattern(
		.plotting_environment$main,
		.indicator,
		OHLC[[2]],
		OHLC[[3]],
		"tasuki_gap"
	)
	.plotting_environment$main
}
