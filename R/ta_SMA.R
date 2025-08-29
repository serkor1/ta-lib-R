#' @title Simple Moving Average (SMA)
#'
#' @description
#' A short description...
#'
#' @param x A univariate series.
#' @param n An [integer] of [length] 1. The window size of the rolling average.
#' @param ... Parameters passed to and from other methods.
#'
#' @family Overlap Study
#'
#' @export
SMA <- function(
	x,
	n = 10,
	cols,
	...
) {
	UseMethod(
		"SMA"
	)
}

#' @export
SMA.default <- function(x, n = 10, cols, ...) {
	if (missing(cols)) {
		cols <- ~open
	}

	x <- series(
		x = cols,
		default = ~open,
		data = x,
		...
	)

	x <- vapply(
		as.list(x),
		FUN = function(x) {
			.Call(
				"impl_ta_MA",
				x,
				as.integer(n),
				0L
			)
		},
		FUN.VALUE = double(nrow(x)),
		USE.NAMES = TRUE
	)

	colnames(x) <- paste0("sma_", colnames(x))

	x
}

#' @export
SMA.numeric <- function(
	x,
	n = 10,
	cols,
	...
) {
	if (!is.missing(cols)) {
		warning(
			"'cols' have been passed but is unused in for vectors"
		)
	}

	.Call(
		"impl_ta_MA",
		as.double(x),
		as.integer(n),
		0L
	)
}

#' @export
SMA.data.frame <- function(
	x,
	n = 10,
	cols,
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @export
SMA.matrix <- function(
	x,
	n = 10,
	cols,
	...
) {
	as.matrix(
		NextMethod()
	)
}

#' @rdname SMA
#' @usage NULL
#' @export
SMA.plotly <- function(x, cols, n = 10, data, ...) {
	## prepare series
	## from
	x <- as.data.frame(
		series(
			x = x,
			formula = cols,
			default = ~open,
			data = data,
			...
		)
	)

	## indicator
	.indicator <- as.data.frame(NextMethod())
	.indicator$idx <- 1:nrow(.indicator)

	for (i in 1:ncol(x)) {
		local({
			j <- i
			.plotting_environment$main <- plotly::add_trace(
				.plotting_environment$main,
				data = .indicator,
				x = ~idx,
				y = ~ .indicator[, j],
				type = "scatter",
				mode = "lines",
				name = sprintf("SMA(%d)", n),
				inherit = FALSE
			)
		})
	}

	.plotting_environment$main
}
