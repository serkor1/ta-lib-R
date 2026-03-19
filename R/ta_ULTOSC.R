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
	na.rm = FALSE,
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
	na.rm = FALSE,
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
		as.integer(n[3]),
		## splice:call:end
		as.logical(na.rm)
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
	na.rm = FALSE,
	...
) {
	map_dfr(
		ultimate_oscillator.default(
			x = x,
			cols = cols,
			n = n,
			na.rm = na.rm,
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
	na.rm = FALSE,
	...
) {
	ultimate_oscillator.default(
		x = x,
		cols = cols,
		n = n,
		na.rm = na.rm,
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
	na.rm = FALSE,
	## splice:optional-plotly:start
	lower_bound = 30,
	upper_bound = 70,
	## splice:optional-plotly:end
	title,
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
		n = n,
		na.rm = TRUE
	)

	## the constructed indicator
	## always returns excpected
	## columns which can be passed
	## down to add_last_values()
	values_to_extract <- colnames(constructed_indicator)

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

	decorators <- list(
		function(p) add_limit(p, y_range = c(0, 100))
	)

	traces <- list(
		plotly_line(upper_bound, nrow(constructed_indicator)),
		plotly_line(lower_bound, nrow(constructed_indicator)),
		list(y = ~ULTOSC)
	)
	## splice:plotly-assembly:end

	plotly_object <- add_last_value(
		build_plotly(
			init = plotly_init(),
			traces = traces,
			decorators = get0(
				x = "decorators",
				ifnotfound = list()
			),
			name = get0(
				x = "name",
				ifnotfound = NULL
			),
			data = constructed_indicator,
			title = if (missing(title)) {
				"Ultimate Oscillator"
			} else {
				title
			}
		),
		data = constructed_indicator[, values_to_extract, drop = FALSE],
		values_to_extract = values_to_extract
	)

	.chart_environment$sub <- c(
		.chart_environment$sub,
		list(plotly_object)
	)

	plotly_object
}
