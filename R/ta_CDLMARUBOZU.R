#' @export
#' @family Pattern Recognition
#'
#' @title Marubozu
#'
#' @templateVar .title Marubozu
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun marubozu
#'
#' @template description
#'
#' @returns
#' \describe{
#'  \item{marubozu}{1 for bullish, -1 for bearish and 0 for no pattern}
#' }
marubozu <- function(x, cols, ...) {
	UseMethod("marubozu")
}

#' @export
#' @usage NULL
#' @rdname marubozu
#' @aliases marubozu
CDLMARUBOZU <- marubozu

#' @usage NULL
#' @aliases marubozu
#' @export
marubozu.default <- function(x, cols, ...) {
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
		"impl_ta_CDLMARUBOZU",
		OHLC[[1]],
		OHLC[[2]],
		OHLC[[3]],
		OHLC[[4]],
		as.logical(getOption("talib.normalize", TRUE))
	))
	colnames(x) <- "marubozu"
	return(x)
}

#' @usage NULL
#' @aliases marubozu
#' @export
marubozu.data.frame <- function(x, cols, ...) {
	as.data.frame(NextMethod())
}

#' @usage NULL
#' @aliases marubozu
#' @export
marubozu.matrix <- function(x, cols, ...) {
	as.matrix(NextMethod())
}

#' @usage NULL
#' @aliases marubozu
#' @export
marubozu.plotly <- function(x, cols, ...) {
	OHLC <- series(
		x = x,
		formula = cols,
		default = ~ open + high + low + close,
		...
	)
	.indicator <- marubozu.default(x = OHLC, cols = ~ open + high + low + close)
	.indicator$idx <- 1:nrow(.indicator)
	.plotting_environment$main <- pattern(
		p = .plotting_environment$main,
		x = .indicator,
		high = OHLC[[2]],
		low = OHLC[[3]],
		pattern_name = "marubozu"
	)
	.plotting_environment$main
}
