#' @export
#' @family Pattern Recognition
#'
#' @title Doji Star
#'
#' @templateVar .title Doji Star
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun doji_star
#'
#' @template description
#'
#' @returns
#' \describe{
#'  \item{doji_star}{1 for bullish, -1 for bearish and 0 for no pattern}
#' }
doji_star <- function(
	x,
	cols,
	...
) {
	UseMethod(
		"doji_star"
	)
}

#' @usage NULL
#' @aliases doji_star
#' @export
CDLDOJISTAR <- doji_star

#' @usage NULL
#' @aliases doji_star
#' @export
doji_star.default <- function(
	x,
	cols,
	...
) {
	## validate input
	## asssuming everyting
	## is numerical values
	if (!missing(cols)) {
		## check if formula
		assert(
			is.formula(cols),
			paste0(
				"'cols' has to be <",
				class(~s),
				">. ",
				"Got <",
				class(cols),
				">."
			)
		)

		## check if formula has the expected
		## length
		assert(
			length(all.vars(cols)) == 4,
			paste0(
				"'cols' has to be length 4. ",
				"Got length ",
				length(all.vars(cols))
			)
		)
	}

	## construct OHLC-series
	## from 'x'
	OHLC <- series(
		x = cols,
		default = ~ open + high + low + close,
		data = x,
		...
	)

	## construct data.frame
	## from source
	x <- as.data.frame(
		.Call(
			"impl_ta_CDLDOJISTAR",
			x[[1]],
			x[[2]],
			x[[3]],
			x[[4]],
			as.logical(
				getOption("talib.normalize", TRUE)
			)
		)
	)

	## set column names
	colnames(x) <- "doji_star"

	## return value
	return(x)
}

#' @usage NULL
#' @aliases doji_star
#' @export
doji_star.data.frame <- function(
	x,
	cols,
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases doji_star
#' @export
doji_star.matrix <- function(
	x,
	cols,
	...
) {
	as.matrix(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases doji_star
#' @export
doji_star.plotly <- function(
	x,
	cols,
	...
) {
	## prepare OHLC series
	OHLC <- series(
		x = x,
		formula = cols,
		default = ~ open + high + low + close,
		...
	)

	## calculate pattern
	## indicators
	.indicator <- doji_star.default(
		x = OHLC,
		cols = ~ open + high + low + close
	)

	.indicator$idx <- 1:nrow(.indicator)

	## chart patterns
	.plotting_environment$main <- pattern(
		p = .plotting_environment$main,
		x = .indicator,
		high = OHLC[[2]],
		low = OHLC[[3]],
		pattern_name = "Doji Star"
	)

	.plotting_environment$main
}
