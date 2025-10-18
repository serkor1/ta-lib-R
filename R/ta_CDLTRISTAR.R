#' @export
#' @family Pattern Recognition
#'
#' @title Tristar
#'
#' @templateVar .title Tristar
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun tristar
#'
#' @template description
#'
#' @returns
#' \describe{
#'  \item{tristar}{1 for bullish, -1 for bearish, 0 for no pattern}
#' }
tristar <- function(x, cols, ...) UseMethod("tristar")

#' @export
#' @usage NULL
#' @rdname tristar
#' @aliases tristar
CDLTRISTAR <- tristar

#' @usage NULL
#' @aliases tristar
#' @export
tristar.default <- function(x, cols, ...) {
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
		"impl_ta_CDLTRISTAR",
		OHLC[[1]],
		OHLC[[2]],
		OHLC[[3]],
		OHLC[[4]],
		as.logical(getOption("talib.normalize", TRUE))
	))
	colnames(x) <- "tristar"
	x
}

#' @export
tristar.data.frame <- function(x, cols, ...) as.data.frame(NextMethod())
#' @export
tristar.matrix <- function(x, cols, ...) as.matrix(NextMethod())
#' @export
tristar.plotly <- function(x, cols, ...) {
	OHLC <- series(
		x = x,
		formula = cols,
		default = ~ open + high + low + close,
		...
	)
	.indicator <- tristar.default(x = OHLC, cols = ~ open + high + low + close)
	.indicator$idx <- 1:nrow(.indicator)
	.plotting_environment$main <- pattern(
		.plotting_environment$main,
		.indicator,
		OHLC[[2]],
		OHLC[[3]],
		"tristar"
	)
	.plotting_environment$main
}
