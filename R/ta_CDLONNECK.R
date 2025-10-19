#' @export
#' @family Pattern Recognition
#'
#' @title On-Neck
#'
#' @templateVar .title On-Neck
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun on_neck
#'
#' @template description
#'
#' @returns
#' \describe{
#'  \item{on_neck}{1 for bullish, -1 for bearish and 0 for no pattern}
#' }
on_neck <- function(x, cols, ...) {
	UseMethod("on_neck")
}

#' @export
#' @usage NULL
#' @rdname on_neck
#' @aliases on_neck
CDLONNECK <- on_neck

#' @usage NULL
#' @aliases on_neck
#' @export
on_neck.default <- function(x, cols, ...) {
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
		"impl_ta_CDLONNECK",
		OHLC[[1]],
		OHLC[[2]],
		OHLC[[3]],
		OHLC[[4]],
		as.logical(getOption("talib.normalize", TRUE))
	))
	colnames(x) <- "on_neck"
	return(x)
}

#' @usage NULL
#' @aliases on_neck
#' @export
on_neck.data.frame <- function(x, cols, ...) {
	as.data.frame(NextMethod())
}

#' @usage NULL
#' @aliases on_neck
#' @export
on_neck.matrix <- function(x, cols, ...) {
	as.matrix(NextMethod())
}

#' @usage NULL
#' @aliases on_neck
#' @export
on_neck.plotly <- function(x, cols, ...) {
	OHLC <- series(
		x = x,
		formula = cols,
		default = ~ open + high + low + close,
		...
	)
	.indicator <- on_neck.default(x = OHLC, cols = ~ open + high + low + close)

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
		pattern_name = "on_neck"
	)
	.plotting_environment$main
}
