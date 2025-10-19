#' @export
#' @family Pattern Recognition
#'
#' @title Piercing
#'
#' @templateVar .title Piercing
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun piercing
#'
#' @template description
#'
#' @returns
#' \describe{
#'  \item{piercing}{1 for bullish, -1 for bearish and 0 for no pattern}
#' }
piercing <- function(x, cols, ...) {
	UseMethod("piercing")
}

#' @export
#' @usage NULL
#' @rdname piercing
#' @aliases piercing
CDLPIERCING <- piercing

#' @usage NULL
#' @aliases piercing
#' @export
piercing.default <- function(x, cols, ...) {
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
		"impl_ta_CDLPIERCING",
		OHLC[[1]],
		OHLC[[2]],
		OHLC[[3]],
		OHLC[[4]],
		as.logical(getOption("talib.normalize", TRUE))
	))
	colnames(x) <- "piercing"
	return(x)
}

#' @usage NULL
#' @aliases piercing
#' @export
piercing.data.frame <- function(x, cols, ...) {
	as.data.frame(NextMethod())
}

#' @usage NULL
#' @aliases piercing
#' @export
piercing.matrix <- function(x, cols, ...) {
	as.matrix(NextMethod())
}

#' @usage NULL
#' @aliases piercing
#' @export
piercing.plotly <- function(x, cols, ...) {
	OHLC <- series(
		x = x,
		formula = cols,
		default = ~ open + high + low + close,
		...
	)
	.indicator <- piercing.default(x = OHLC, cols = ~ open + high + low + close)

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
		pattern_name = "piercing"
	)
	.plotting_environment$main
}
