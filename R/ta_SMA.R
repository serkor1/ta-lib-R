#' @export
#' @family Overlap Study
#' @title Simple Moving Average (SMA)
#'
#' @templateVar .title Simple Moving Average (SMA)
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun SMA
#'
#' @template description
SMA <- function(
	x,
	cols,
	n = 10,
	...
) {
	UseMethod(
		"SMA"
	)
}

#' @rdname SMA
#' @usage NULL
#' @export
simple_moving_average <- SMA

#' @rdname SMA
#' @usage NULL
#' @export
SMA.default <- function(
	x,
	cols,
	n = 10,
	...
) {
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

#' @rdname SMA
#' @usage NULL
#' @export
SMA.numeric <- function(
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
		0L
	)
}

#' @rdname SMA
#' @usage NULL
#' @export
SMA.data.frame <- function(
	x,
	cols,
	n = 10,
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @rdname SMA
#' @usage NULL
#' @export
SMA.matrix <- function(
	x,
	cols,
	n = 10,
	...
) {
	as.matrix(
		NextMethod()
	)
}

#' @rdname SMA
#' @usage NULL
#' @export
SMA.plotly <- function(
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
				name = sprintf("SMA(%d)", n),
				inherit = FALSE
			)
		})
	}

	.plotting_environment$main
}
