#' @export
#' @family Pattern Recognition
#'
#' @title Takuri
#'
#' @templateVar .title Takuri
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun takuri
#'
#' @template description
#'
#' @returns
#' \describe{
#'  \item{takuri}{1 for bullish reversal, 0 for no pattern}
#' }
takuri <- function(x, cols, ...) UseMethod("takuri")

#' @export
#' @usage NULL
#' @rdname takuri
#' @aliases takuri
CDLTAKURI <- takuri

#' @export
takuri.default <- function(x, cols, ...) {
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
		"impl_ta_CDLTAKURI",
		OHLC[[1]],
		OHLC[[2]],
		OHLC[[3]],
		OHLC[[4]],
		as.logical(getOption("talib.normalize", TRUE))
	))
	colnames(x) <- "takuri"
	x
}

#' @export
takuri.data.frame <- function(x, cols, ...) as.data.frame(NextMethod())
#' @export
takuri.matrix <- function(x, cols, ...) as.matrix(NextMethod())
#' @export
takuri.plotly <- function(x, cols, ...) {
	OHLC <- series(
		x = x,
		formula = cols,
		default = ~ open + high + low + close,
		...
	)
	.indicator <- takuri.default(x = OHLC, cols = ~ open + high + low + close)
	.indicator$idx <- 1:nrow(.indicator)
	.plotting_environment$main <- pattern(
		.plotting_environment$main,
		.indicator,
		OHLC[[2]],
		OHLC[[3]],
		"takuri"
	)
	.plotting_environment$main
}
