#' @export
#' @family Momentum Indicator
#' @title Ultimate Oscillator
#'
#' @templateVar .title Ultimate Oscillator
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun ultimate_oscillator
#'
#' @template description
ultimate_oscillator <- function(
	x,
	cols,
	n = c(7, 14, 28),
	...
) {
	UseMethod(
		"ultimate_oscillator"
	)
}

#' @export
#'
#' @usage NULL
#'
#' @rdname ultimate_oscillator
#' @aliases ultimate_oscillator
ULTOSC <- ultimate_oscillator

#' @rdname ultimate_oscillator
#' @usage NULL
#' @export
ultimate_oscillator.default <- function(
	x,
	cols,
	n = c(7, 14, 28),
	...
) {
	## default behaviour is to
	## coerce to a `matrix` check that
	## it is double and then pass to
	## C-side.

	## 0) validate input
	##    and stop the script
	##    if conditions are not
	##    met
	if (!length(n) == 3) {
		stop("`n` has to be a vector of length 3")
	}

	HLC <- series(
		x = cols,
		default = ~ high + low + close,
		data = x,
		...
	)

	## 1) pass `x` assuming that it
	##    follows OHLC-V structure
	x <- as.data.frame(
		.Call(
			"impl_ta_ULTOSC",
			HLC[[1]],
			HLC[[2]],
			HLC[[3]],
			as.integer(n[1]),
			as.integer(n[2]),
			as.integer(n[3])
		)
	)

	colnames(x) <- "utimate_oscillator"

	return(x)
}

#' @rdname ultimate_oscillator
#' @usage NULL
#' @export
ultimate_oscillator.data.frame <- function(
	x,
	cols,
	n = c(7, 14, 28),
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @rdname ultimate_oscillator
#' @usage NULL
#' @export
ultimate_oscillator.matrix <- function(
	x,
	cols,
	n = c(7, 14, 28),
	...
) {
	as.matrix(
		NextMethod()
	)
}

#' @rdname ultimate_oscillator
#' @usage NULL
#' @export
ultimate_oscillator.plotly <- function(
	x,
	cols,
	n = c(7, 14, 28),
	...
) {
	## prepare series
	## from
	x <- as.data.frame(
		series(
			x = x,
			formula = cols,
			default = ~ high + low + close,
			...
		)
	)

	## indicator
	.indicator <- as.data.frame(NextMethod())
	.indicator$idx <- 1:nrow(.indicator)

	# plot
	output <- plotly::plot_ly(
		data = .indicator,
		x = ~idx,
		y = ~utimate_oscillator,
		type = "scatter",
		mode = "lines",
		name = "Ultimate Oscillator",
		legendgroup = "ultimate_oscillator",
		showlegend = TRUE
	)

	output <- add_title(
		x = output,
		text = "Ultimate Oscillator"
	)

	.plotting_environment$sub <- c(
		.plotting_environment$sub,
		list(output)
	)

	output
}
