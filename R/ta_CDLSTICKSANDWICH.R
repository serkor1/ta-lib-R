#' @export
#' @family Pattern Recognition
#'
#' @title Stick Sandwich
#'
#' @templateVar .title Stick Sandwich
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun stick_sandwich
#'
#' @template description
#'
#' @returns
#' \describe{
#'  \item{stick_sandwich}{1 for bullish reversal, 0 for no pattern}
#' }
stick_sandwich <- function(x, cols, ...) UseMethod("stick_sandwich")

#' @export
#' @usage NULL
#' @rdname stick_sandwich
#' @aliases stick_sandwich
CDLSTICKSANDWICH <- stick_sandwich

#' @export
stick_sandwich.default <- function(x, cols, ...) {
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
		"impl_ta_CDLSTICKSANDWICH",
		OHLC[[1]],
		OHLC[[2]],
		OHLC[[3]],
		OHLC[[4]],
		as.logical(getOption("talib.normalize", TRUE))
	))
	colnames(x) <- "stick_sandwich"
	x
}

#' @export
stick_sandwich.data.frame <- function(x, cols, ...) as.data.frame(NextMethod())
#' @export
stick_sandwich.matrix <- function(x, cols, ...) as.matrix(NextMethod())
#' @export
stick_sandwich.plotly <- function(x, cols, ...) {
	OHLC <- series(
		x = x,
		formula = cols,
		default = ~ open + high + low + close,
		...
	)
	.indicator <- stick_sandwich.default(
		x = OHLC,
		cols = ~ open + high + low + close
	)
	.indicator$idx <- 1:nrow(.indicator)
	.plotting_environment$main <- pattern(
		.plotting_environment$main,
		.indicator,
		OHLC[[2]],
		OHLC[[3]],
		"stick_sandwich"
	)
	.plotting_environment$main
}
