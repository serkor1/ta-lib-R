#' @export
#' @family Pattern Recognition
#'
#' @title Matching Low
#'
#' @templateVar .title Matching Low
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun matching_low
#'
#' @template description
#'
#' @returns
#' \describe{
#'  \item{matching_low}{1 for bullish, -1 for bearish and 0 for no pattern}
#' }
matching_low <- function(x, cols, ...) {
	UseMethod("matching_low")
}

#' @export
#' @usage NULL
#' @rdname matching_low
#' @aliases matching_low
CDLMATCHINGLOW <- matching_low

#' @usage NULL
#' @aliases matching_low
#' @export
matching_low.default <- function(x, cols, ...) {
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
		"impl_ta_CDLMATCHINGLOW",
		OHLC[[1]],
		OHLC[[2]],
		OHLC[[3]],
		OHLC[[4]],
		as.logical(getOption("talib.normalize", TRUE))
	))
	colnames(x) <- "matching_low"
	return(x)
}

#' @usage NULL
#' @aliases matching_low
#' @export
matching_low.data.frame <- function(x, cols, ...) {
	as.data.frame(NextMethod())
}

#' @usage NULL
#' @aliases matching_low
#' @export
matching_low.matrix <- function(x, cols, ...) {
	as.matrix(NextMethod())
}

#' @usage NULL
#' @aliases matching_low
#' @export
matching_low.plotly <- function(x, cols, ...) {
	OHLC <- series(
		x = x,
		formula = cols,
		default = ~ open + high + low + close,
		...
	)
	.indicator <- matching_low.default(
		x = OHLC,
		cols = ~ open + high + low + close
	)
	.indicator$idx <- 1:nrow(.indicator)
	.plotting_environment$main <- pattern(
		p = .plotting_environment$main,
		x = .indicator,
		high = OHLC[[2]],
		low = OHLC[[3]],
		pattern_name = "matching_low"
	)
	.plotting_environment$main
}
