#' @export
#' @family Pattern Recognition
#'
#' @title Stalled Pattern
#'
#' @templateVar .title Stalled Pattern
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun stalled_pattern
#'
#' @template description
#'
#' @returns
#' \describe{
#'  \item{stalled_pattern}{-1 for bearish reversal, 0 for no pattern}
#' }
stalled_pattern <- function(x, cols, ...) UseMethod("stalled_pattern")

#' @export
#' @usage NULL
#' @rdname stalled_pattern
#' @aliases stalled_pattern
CDLSTALLEDPATTERN <- stalled_pattern

#' @export
stalled_pattern.default <- function(x, cols, ...) {
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
		"impl_ta_CDLSTALLEDPATTERN",
		OHLC[[1]],
		OHLC[[2]],
		OHLC[[3]],
		OHLC[[4]],
		as.logical(getOption("talib.normalize", TRUE))
	))
	colnames(x) <- "stalled_pattern"
	x
}

#' @export
stalled_pattern.data.frame <- function(x, cols, ...) as.data.frame(NextMethod())
#' @export
stalled_pattern.matrix <- function(x, cols, ...) as.matrix(NextMethod())
#' @export
stalled_pattern.plotly <- function(x, cols, ...) {
	OHLC <- series(
		x = x,
		formula = cols,
		default = ~ open + high + low + close,
		...
	)
	.indicator <- stalled_pattern.default(
		x = OHLC,
		cols = ~ open + high + low + close
	)

	## add x-axis conditional on whether
	## the data have been subsetted or not
	.indicator$idx <- add_idx(
		OHLC
	)

	.plotting_environment$main <- pattern(
		.plotting_environment$main,
		.indicator,
		OHLC[[2]],
		OHLC[[3]],
		"stalled_pattern"
	)
	.plotting_environment$main
}
