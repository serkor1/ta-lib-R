#' @export
#' @family Pattern Recognition
#'
#' @title Shooting Star
#'
#' @templateVar .title Shooting Star
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun shooting_star
#'
#' @template description
#'
#' @returns
#' \describe{
#'  \item{shooting_star}{-1 for bearish reversal, 0 for no pattern}
#' }
shooting_star <- function(x, cols, ...) UseMethod("shooting_star")

#' @export
#' @usage NULL
#' @rdname shooting_star
#' @aliases shooting_star
CDLSHOOTINGSTAR <- shooting_star

#' @export
shooting_star.default <- function(x, cols, ...) {
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
		"impl_ta_CDLSHOOTINGSTAR",
		OHLC[[1]],
		OHLC[[2]],
		OHLC[[3]],
		OHLC[[4]],
		as.logical(getOption("talib.normalize", TRUE))
	))
	colnames(x) <- "shooting_star"
	x
}

#' @export
shooting_star.data.frame <- function(x, cols, ...) as.data.frame(NextMethod())
#' @export
shooting_star.matrix <- function(x, cols, ...) as.matrix(NextMethod())
#' @export
shooting_star.plotly <- function(x, cols, ...) {
	OHLC <- series(
		x = x,
		formula = cols,
		default = ~ open + high + low + close,
		...
	)
	.indicator <- shooting_star.default(
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
		"shooting_star"
	)
	.plotting_environment$main
}
