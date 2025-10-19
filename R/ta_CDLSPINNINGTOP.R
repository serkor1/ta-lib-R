#' @export
#' @family Pattern Recognition
#'
#' @title Spinning Top
#'
#' @templateVar .title Spinning Top
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun spinning_top
#'
#' @template description
#'
#' @returns
#' \describe{
#'  \item{spinning_top}{1 white, -1 black, 0 no spinning top}
#' }
spinning_top <- function(x, cols, ...) UseMethod("spinning_top")

#' @export
#' @usage NULL
#' @rdname spinning_top
#' @aliases spinning_top
CDLSPINNINGTOP <- spinning_top

#' @export
spinning_top.default <- function(x, cols, ...) {
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
		"impl_ta_CDLSPINNINGTOP",
		OHLC[[1]],
		OHLC[[2]],
		OHLC[[3]],
		OHLC[[4]],
		as.logical(getOption("talib.normalize", TRUE))
	))
	colnames(x) <- "spinning_top"
	x
}

#' @export
spinning_top.data.frame <- function(x, cols, ...) as.data.frame(NextMethod())
#' @export
spinning_top.matrix <- function(x, cols, ...) as.matrix(NextMethod())
#' @export
spinning_top.plotly <- function(x, cols, ...) {
	OHLC <- series(
		x = x,
		formula = cols,
		default = ~ open + high + low + close,
		...
	)
	.indicator <- spinning_top.default(
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
		"spinning_top"
	)
	.plotting_environment$main
}
