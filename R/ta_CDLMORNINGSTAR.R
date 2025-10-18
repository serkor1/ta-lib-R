#' @export
#' @family Pattern Recognition
#'
#' @title Morning Star
#'
#' @templateVar .title Morning Star
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun morning_star
#'
#' @template description
#'
#' @returns
#' \describe{
#'  \item{morning_star}{1 for bullish, -1 for bearish and 0 for no pattern}
#' }
morning_star <- function(
	x,
	cols,
	eps = 0,
	...
) {
	UseMethod("morning_star")
}

#' @export
#' @usage NULL
#' @rdname morning_star
#' @aliases morning_star
CDLMORNINGSTAR <- morning_star

#' @usage NULL
#' @aliases morning_star
#' @export
morning_star.default <- function(
	x,
	cols,
	eps = 0,
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
		"impl_ta_CDLMORNINGSTAR",
		OHLC[[1]],
		OHLC[[2]],
		OHLC[[3]],
		OHLC[[4]],
		as.numeric(eps),
		as.logical(getOption("talib.normalize", TRUE))
	))
	colnames(x) <- "morning_star"
	return(x)
}

#' @usage NULL
#' @aliases morning_star
#' @export
morning_star.data.frame <- function(x, cols, eps = 0, ...) {
	as.data.frame(NextMethod())
}

#' @usage NULL
#' @aliases morning_star
#' @export
morning_star.matrix <- function(x, cols, eps = 0, ...) {
	as.matrix(NextMethod())
}

#' @usage NULL
#' @aliases morning_star
#' @export
morning_star.plotly <- function(x, cols, eps = 0, ...) {
	OHLC <- series(
		x = x,
		formula = cols,
		default = ~ open + high + low + close,
		...
	)
	.indicator <- morning_star.default(
		x = OHLC,
		cols = ~ open + high + low + close,
		eps = eps
	)
	.indicator$idx <- 1:nrow(.indicator)
	.plotting_environment$main <- pattern(
		p = .plotting_environment$main,
		x = .indicator,
		high = OHLC[[2]],
		low = OHLC[[3]],
		pattern_name = "morning_star"
	)
	.plotting_environment$main
}
