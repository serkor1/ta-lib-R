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
	lower_bound = 30,
	upper_bound = 70,
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
	name <- sprintf(
		"UltOsc(%d, %d, %d)",
		n[1],
		n[2],
		n[3]
	)
	plotly_object <- subchart(
		data = constructed_indicator,
		y = ~ULTOSC,
		type = "scatter",
		mode = "lines",
		name = "Ultimate Oscillator",
		legendgroup = "ultimate_oscillator",
		showlegend = TRUE
	)

	traces <- list(
		plotly_line(upper_bound, nrow(constructed_indicator)),
		plotly_line(lower_bound, nrow(constructed_indicator))
	)
	## splice:plotly-assembly:end

	plotly_object <- build_plotly(
		init = plotly_init(),
		traces = traces,
		name = name,
		data = constructed_indicator
	)

	.plotting_environment$sub <- c(
		.plotting_environment$sub,
		list(plotly_object)
	)

	plotly_object
}
