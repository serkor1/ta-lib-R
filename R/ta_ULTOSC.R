#' @export
#' @family Momentum Indicator
#'
#' @title Ultimate Oscillator
#' @templateVar .title Ultimate Oscillator
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun ultimate_oscillator
#' @templateVar .family Momentum Indicator
#' @templateVar .formula ~ high + low + close
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
#' @template returns
ultimate_oscillator <- function(
	x,
	cols,
	n = c(7, 14, 28),
	...
) {
	UseMethod("ultimate_oscillator")
}

#' @export
#' @usage NULL
#' @rdname ultimate_oscillator
#'
#' @aliases ultimate_oscillator
ULTOSC <- ultimate_oscillator

#' @usage NULL
#' @aliases ultimate_oscillator
#'
#' @export
ultimate_oscillator.default <- function(
	x,
	cols,
	n = c(7, 14, 28),
	...
) {
	## validate 'cols'-argument
	## if explicitly passed
	if (!missing(cols)) {
		assert_formula(cols)
	}

	## construct series
	## from input
	constructed_series <- series(
		x = cols,
		default = ~ high + low + close,
		data = x,
		...
	)

	## extract rownames
	## for later attachment
	x_names <- rownames(constructed_series)

	## calculate indicator and
	## return as data.frame
	x <- .Call(
		"impl_ta_ULTOSC",
		## splice:call:start
		constructed_series[[1]],
		constructed_series[[2]],
		constructed_series[[3]],
		as.integer(n[1]),
		as.integer(n[2]),
		as.integer(n[3])
		## splice:call:end
	)

	## readd rownames
	set_rownames(x, x_names)

	## return indicator
	x
}

#' @usage NULL
#' @aliases ultimate_oscillator
#'
#' @export
ultimate_oscillator.data.frame <- function(
	x,
	cols,
	n = c(7, 14, 28),
	...
) {
	map_dfr(
		ultimate_oscillator.default(
			x = x,
			cols = cols,
			n = n,
			...
		)
	)
}

#' @usage NULL
#' @aliases ultimate_oscillator
#'
#' @export
ultimate_oscillator.matrix <- function(
	x,
	cols,
	n = c(7, 14, 28),
	...
) {
	ultimate_oscillator.default(
		x = x,
		cols = cols,
		n = n,
		...
	)
}

#' @usage NULL
#' @aliases ultimate_oscillator
#'
#' @export
ultimate_oscillator.plotly <- function(
	x,
	cols,
	n = c(7, 14, 28),
	## splice:optional-plotly:start
	lower = 30,
	upper = 70,
	## splice:optional-plotly:end
	...
) {
	## check that input value
	## 'x' is <plotly>-object
	assert_plotly(x)

	## check that input value
	## 'cols' is a <formula>-objet
	if (!missing(cols)) {
		assert_formula(cols)
	}

	## construct series from
	## {plotly}-object
	constructed_series <- series(
		x = x,
		formula = cols,
		default = ~ high + low + close,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- ultimate_oscillator(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		n = n
	)

	## add conditional idx
	constructed_indicator[["idx"]] <- add_idx(
		constructed_series
	)

	## construct {plotly}-object
	## splice:plotly-assembly:start
	plotly_object <- subchart(
		data = constructed_indicator,
		y = ~ULTOSC,
		type = "scatter",
		mode = "lines",
		name = "Ultimate Oscillator",
		legendgroup = "ultimate_oscillator",
		showlegend = TRUE
	)

	plotly_object <- add_ribbons(
		plotly_object = plotly_object,
		data = constructed_indicator,
		x = ~idx,
		ymin = rep(lower, nrow(constructed_indicator)),
		ymax = rep(upper, nrow(constructed_indicator)),
		color = "lightgray",
		alpha = 0.2,
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
	## splice:plotly-assembly:end

	plotly_object
}
