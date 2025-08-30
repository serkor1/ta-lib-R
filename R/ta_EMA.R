#' @export
#' @family Overlap Study
#' @title Exponential Moving Average (EMA)
#'
#' @templateVar .title Exponential Moving Average (EMA)
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun EMA
#'
#' @template description
EMA <- function(
	x,
	cols,
	n = 10,
	...
) {
	UseMethod("EMA")
}

#' @rdname EMA
#' @usage NULL
#' @export
exponential_moving_average <- EMA

#' @rdname EMA
#' @usage NULL
#' @export
EMA.default <- function(
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
				1L
			)
		},
		FUN.VALUE = double(nrow(x)),
		USE.NAMES = TRUE
	)

	colnames(x) <- paste0("ema_", colnames(x))

	x
}

#' @rdname EMA
#' @usage NULL
#' @export
EMA.numeric <- function(
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
		1L
	)
}


#' @rdname EMA
#' @usage NULL
#' @export
EMA.data.frame <- function(
	x,
	n = 10,
	cols,
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @rdname EMA
#' @usage NULL
#' @export
EMA.matrix <- function(
	x,
	n = 10,
	cols,
	...
) {
	as.matrix(
		NextMethod()
	)
}

#' @rdname EMA
#' @usage NULL
#' @export
EMA.plotly <- function(
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
				name = sprintf("EMA(%d)", n),
				inherit = FALSE
			)
		})
	}

	.plotting_environment$main
}
