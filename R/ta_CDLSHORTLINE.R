#' @export
#' @family Pattern Recognition
#'
#' @title Short Line Candle
#'
#' @templateVar .title Short Line Candle
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun short_line
#'
#' @template description
#'
#' @returns
#' \describe{
#'  \item{short_line}{1 white, -1 black, 0 no short line}
#' }
short_line <- function(x, cols, ...) UseMethod("short_line")

#' @export
#' @usage NULL
#' @rdname short_line
#' @aliases short_line
CDLSHORTLINE <- short_line

#' @export
short_line.default <- function(x, cols, ...) {
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
		"impl_ta_CDLSHORTLINE",
		OHLC[[1]],
		OHLC[[2]],
		OHLC[[3]],
		OHLC[[4]],
		as.logical(getOption("talib.normalize", TRUE))
	))
	colnames(x) <- "short_line"
	x
}

#' @export
short_line.data.frame <- function(x, cols, ...) as.data.frame(NextMethod())
#' @export
short_line.matrix <- function(x, cols, ...) as.matrix(NextMethod())
#' @export
short_line.plotly <- function(x, cols, ...) {
	OHLC <- series(
		x = x,
		formula = cols,
		default = ~ open + high + low + close,
		...
	)
	.indicator <- short_line.default(
		x = OHLC,
		cols = ~ open + high + low + close
	)
	.indicator$idx <- 1:nrow(.indicator)
	.plotting_environment$main <- pattern(
		.plotting_environment$main,
		.indicator,
		OHLC[[2]],
		OHLC[[3]],
		"short_line"
	)
	.plotting_environment$main
}
