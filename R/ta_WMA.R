#' @export
#' @family Overlap Study
#' @title Weighted Moving Average (WMA)
#'
#' @templateVar .title Weighted Moving Average (WMA)
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun WMA
#'
#' @template description
WMA <- function(
	x,
	cols,
	n = 10,
	...
) {
	UseMethod("WMA")
}

#' @rdname WMA
#' @usage NULL
#' @export
weighted_moving_average <- WMA

#' @rdname WMA
#' @usage NULL
#' @export
WMA.default <- function(
	x,
	cols,
	n = 10,
	...
) {
	## default behaviour is to
	## check if its a numeric vector
	##
	## No coercing here as it might
	## lead to overflow
	x <- series(
		x = cols,
		default = ~open,
		data = x,
		...
	)

	## 0) validate input
	##    and stop the script
	##    if conditions are not
	##    met
	x <- vapply(
		as.list(x),
		FUN = function(x) {
			.Call(
				"impl_ta_MA",
				x,
				as.integer(n),
				2L
			)
		},
		FUN.VALUE = double(nrow(x)),
		USE.NAMES = TRUE
	)

	colnames(x) <- paste0("wma_", colnames(x))

	x
}

#' @rdname WMA
#' @usage NULL
#' @export
WMA.numeric <- function(
	x,
	cols,
	n = 10,
	...
) {
	if (!missing(cols)) {
		warning(
			"'cols' have been passed but is unused in for vectors"
		)
	}

	.Call(
		"impl_ta_MA",
		as.double(x),
		as.integer(n),
		2L
	)
}


#' @rdname WMA
#' @usage NULL
#' @export
WMA.data.frame <- function(
	x,
	n = 10,
	cols,
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @rdname WMA
#' @usage NULL
#' @export
WMA.matrix <- function(
	x,
	n = 10,
	cols,
	...
) {
	as.matrix(
		NextMethod()
	)
}

#' @rdname WMA
#' @usage NULL
#' @export
WMA.plotly <- function(
	x,
	cols,
	n = 10,
	data,
	...
) {
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
				name = sprintf("WMA(%d)", n),
				inherit = FALSE
			)
		})
	}

	.plotting_environment$main
}
