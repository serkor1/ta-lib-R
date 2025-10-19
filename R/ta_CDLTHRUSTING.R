#' @export
#' @family Pattern Recognition
#'
#' @title Thrusting
#'
#' @templateVar .title Thrusting
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun thrusting
#'
#' @template description
#'
#' @returns
#' \describe{
#'  \item{thrusting}{-1 for bearish continuation, 0 for no pattern}
#' }
thrusting <- function(x, cols, ...) UseMethod("thrusting")

#' @export
#' @usage NULL
#' @rdname thrusting
#' @aliases thrusting
CDLTHRUSTING <- thrusting

#' @export
thrusting.default <- function(x, cols, ...) {
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
		"impl_ta_CDLTHRUSTING",
		OHLC[[1]],
		OHLC[[2]],
		OHLC[[3]],
		OHLC[[4]],
		as.logical(getOption("talib.normalize", TRUE))
	))
	colnames(x) <- "thrusting"
	x
}

#' @export
thrusting.data.frame <- function(x, cols, ...) as.data.frame(NextMethod())
#' @export
thrusting.matrix <- function(x, cols, ...) as.matrix(NextMethod())
#' @export
thrusting.plotly <- function(x, cols, ...) {
	OHLC <- series(
		x = x,
		formula = cols,
		default = ~ open + high + low + close,
		...
	)
	.indicator <- thrusting.default(
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
		"thrusting"
	)
	.plotting_environment$main
}
