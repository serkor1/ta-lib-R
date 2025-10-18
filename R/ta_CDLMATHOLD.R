#' @export
#' @family Pattern Recognition
#'
#' @title Mat Hold
#'
#' @templateVar .title Mat Hold
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun mat_hold
#'
#' @template description
#'
#' @returns
#' \describe{
#'  \item{mat_hold}{1 for bullish, -1 for bearish and 0 for no pattern}
#' }
mat_hold <- function(
	x,
	cols,
	eps = 0,
	...
) {
	UseMethod("mat_hold")
}

#' @export
#' @usage NULL
#' @rdname mat_hold
#' @aliases mat_hold
CDLMATHOLD <- mat_hold

#' @usage NULL
#' @aliases mat_hold
#' @export
mat_hold.default <- function(
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
		"impl_ta_CDLMATHOLD",
		OHLC[[1]],
		OHLC[[2]],
		OHLC[[3]],
		OHLC[[4]],
		as.numeric(eps),
		as.logical(getOption("talib.normalize", TRUE))
	))
	colnames(x) <- "mat_hold"
	return(x)
}

#' @usage NULL
#' @aliases mat_hold
#' @export
mat_hold.data.frame <- function(x, cols, eps = 0, ...) {
	as.data.frame(NextMethod())
}

#' @usage NULL
#' @aliases mat_hold
#' @export
mat_hold.matrix <- function(x, cols, eps = 0, ...) {
	as.matrix(NextMethod())
}

#' @usage NULL
#' @aliases mat_hold
#' @export
mat_hold.plotly <- function(x, cols, eps = 0, ...) {
	OHLC <- series(
		x = x,
		formula = cols,
		default = ~ open + high + low + close,
		...
	)
	.indicator <- mat_hold.default(
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
		pattern_name = "mat_hold"
	)
	.plotting_environment$main
}
