#' @export
#' @family Pattern Recognition
#'
#' @title Separating Lines
#'
#' @templateVar .title Separating Lines
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun separating_lines
#'
#' @template description
#'
#' @returns
#' \describe{
#'  \item{separating_lines}{1 for bullish continuation, -1 for bearish continuation, 0 for no pattern}
#' }
separating_lines <- function(x, cols, ...) UseMethod("separating_lines")

#' @export
#' @usage NULL
#' @rdname separating_lines
#' @aliases separating_lines
CDLSEPARATINGLINES <- separating_lines

#' @export
separating_lines.default <- function(x, cols, ...) {
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
		"impl_ta_CDLSEPARATINGLINES",
		OHLC[[1]],
		OHLC[[2]],
		OHLC[[3]],
		OHLC[[4]],
		as.logical(getOption("talib.normalize", TRUE))
	))
	colnames(x) <- "separating_lines"
	x
}

#' @export
separating_lines.data.frame <- function(x, cols, ...) {
	as.data.frame(NextMethod())
}
#' @export
separating_lines.matrix <- function(x, cols, ...) as.matrix(NextMethod())
#' @export
separating_lines.plotly <- function(x, cols, ...) {
	OHLC <- series(
		x = x,
		formula = cols,
		default = ~ open + high + low + close,
		...
	)
	.indicator <- separating_lines.default(
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
		"separating_lines"
	)
	.plotting_environment$main
}
