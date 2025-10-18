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
	lower = 30,
	upper = 70,
	color = "lightgray",
	alpha = 0.7,
	...
) {
	## prepare HLC
	## series for ultimate
	## oscillator
	HLC <- as.data.frame(
		series(
			x = x,
			formula = cols,
			default = ~ high + low + close,
			...
		)
	)

	## calculate indicator
	## and return as data.frame
	.indicator <- ultimate_oscillator.default(
		x = HLC,
		cols = rebuild_formula(
			names(HLC)
		),
		n = n
	)

	## add x-axis conditional on whether
	## the data have been subsetted or not
	.indicator$idx <- add_idx(
		HLC
	)

	# plot
	plotly_object <- subchart(
		data = .indicator,
		y = ~utimate_oscillator,
		type = "scatter",
		mode = "lines",
		name = "Ultimate Oscillator",
		legendgroup = "ultimate_oscillator",
		showlegend = TRUE
	)

	plotly_object <- add_ribbons(
		plotly_object = plotly_object,
		data = .indicator,
		x = ~idx,
		ymin = rep(lower, nrow(.indicator)),
		ymax = rep(upper, nrow(.indicator)),
		color = color,
		alpha = alpha,
		showlegend = TRUE,
		dash = c("dot", "dot"),
		name = c("Lower", "Upper"),
		legendgroup = "stochrsi"
	)

	if (main_chart_exists()) {
		plotly_object <- add_title(
			x = plotly_object,
			text = "Ultimate Oscillator"
		)
	}

	.plotting_environment$sub <- c(
		.plotting_environment$sub,
		list(plotly_object)
	)

	plotly_object
}
