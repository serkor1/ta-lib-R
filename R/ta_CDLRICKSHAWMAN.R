#' @export
#' @family Pattern Recognition
#'
#' @title Rickshaw Man
#'
#' @templateVar .title Rickshaw Man
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun rickshaw_man
#'
#' @template description
#'
#' @returns
#' \describe{
#'  \item{rickshaw_man}{1 for bullish, -1 for bearish and 0 for no pattern}
#' }
rickshaw_man <- function(x, cols, ...) {
	UseMethod("rickshaw_man")
}

#' @export
#' @usage NULL
#' @rdname rickshaw_man
#' @aliases rickshaw_man
CDLRICKSHAWMAN <- rickshaw_man

#' @usage NULL
#' @aliases rickshaw_man
#' @export
rickshaw_man.default <- function(x, cols, ...) {
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
		"impl_ta_CDLRICKSHAWMAN",
		OHLC[[1]],
		OHLC[[2]],
		OHLC[[3]],
		OHLC[[4]],
		as.logical(getOption("talib.normalize", TRUE))
	))
	colnames(x) <- "rickshaw_man"
	return(x)
}

#' @usage NULL
#' @aliases rickshaw_man
#' @export
rickshaw_man.data.frame <- function(x, cols, ...) {
	as.data.frame(NextMethod())
}

#' @usage NULL
#' @aliases rickshaw_man
#' @export
rickshaw_man.matrix <- function(x, cols, ...) {
	as.matrix(NextMethod())
}

#' @usage NULL
#' @aliases rickshaw_man
#' @export
rickshaw_man.plotly <- function(x, cols, ...) {
	OHLC <- series(
		x = x,
		formula = cols,
		default = ~ open + high + low + close,
		...
	)
	.indicator <- rickshaw_man.default(
		x = OHLC,
		cols = ~ open + high + low + close
	)
	.indicator$idx <- 1:nrow(.indicator)
	.plotting_environment$main <- pattern(
		p = .plotting_environment$main,
		x = .indicator,
		high = OHLC[[2]],
		low = OHLC[[3]],
		pattern_name = "rickshaw_man"
	)
	.plotting_environment$main
}
