#' @export
#' @family Pattern Recognition
#'
#' @title Rising/Falling Three Methods
#'
#' @templateVar .title Rising/Falling Three Methods
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun rise_fall_3_methods
#'
#' @template description
#'
#' @returns
#' \describe{
#'  \item{rise_fall_3_methods}{1 for bullish continuation, -1 for bearish continuation, 0 for no pattern}
#' }
rise_fall_3_methods <- function(x, cols, ...) UseMethod("rise_fall_3_methods")

#' @export
#' @usage NULL
#' @rdname rise_fall_3_methods
#' @aliases rise_fall_3_methods
CDLRISEFALL3METHODS <- rise_fall_3_methods

#' @export
rise_fall_3_methods.default <- function(x, cols, ...) {
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
		"impl_ta_CDLRISEFALL3METHODS",
		OHLC[[1]],
		OHLC[[2]],
		OHLC[[3]],
		OHLC[[4]],
		as.logical(getOption("talib.normalize", TRUE))
	))
	colnames(x) <- "rise_fall_3_methods"
	x
}

#' @export
rise_fall_3_methods.data.frame <- function(x, cols, ...) {
	as.data.frame(NextMethod())
}
#' @export
rise_fall_3_methods.matrix <- function(x, cols, ...) as.matrix(NextMethod())
#' @export
rise_fall_3_methods.plotly <- function(x, cols, ...) {
	OHLC <- series(
		x = x,
		formula = cols,
		default = ~ open + high + low + close,
		...
	)
	.indicator <- rise_fall_3_methods.default(
		x = OHLC,
		cols = ~ open + high + low + close
	)
	.indicator$idx <- 1:nrow(.indicator)
	.plotting_environment$main <- pattern(
		.plotting_environment$main,
		.indicator,
		OHLC[[2]],
		OHLC[[3]],
		"rise_fall_3_methods"
	)
	.plotting_environment$main
}
