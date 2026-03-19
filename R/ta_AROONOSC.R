#' @export
#' @family Momentum Indicator
#'
#' @title Aroon Oscillator
#' @templateVar .title Aroon Oscillator
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun aroon_oscillator
#' @templateVar .family Momentum Indicator
#' @templateVar .formula ~ high + low
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
#' @template returns
aroon_oscillator <- function(
	x,
	cols,
	n = 10,
	na.rm = FALSE,
	...
) {
	UseMethod("aroon_oscillator")
}

#' @export
#' @usage NULL
#' @rdname aroon_oscillator
#'
#' @aliases aroon_oscillator
AROONOSC <- aroon_oscillator

#' @usage NULL
#' @aliases aroon_oscillator
#'
#' @export
aroon_oscillator.default <- function(
	x,
	cols,
	n = 10,
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
		default = ~ high + low,
		data = x,
		...
	)

	## extract rownames
	## for later attachment
	x_names <- rownames(constructed_series)

	## calculate indicator and
	## return as data.frame
	x <- .Call(
		"impl_ta_AROONOSC",
		## splice:call:start
		constructed_series[[1]],
		constructed_series[[2]],
		as.integer(n),
		## splice:call:end
		,
		as.logical(na.rm)
	)

	## readd rownames
	set_rownames(x, x_names)

	## return indicator
	x
}

#' @usage NULL
#' @aliases aroon_oscillator
#'
#' @export
aroon_oscillator.data.frame <- function(
	x,
	cols,
	n = 10,
	na.rm = FALSE,
	...
) {
	map_dfr(
		aroon_oscillator.default(
			x = x,
			cols = cols,
			n = n,
			na.rm = na.rm,
			...
		)
	)
}

#' @usage NULL
#' @aliases aroon_oscillator
#'
#' @export
aroon_oscillator.matrix <- function(
	x,
	cols,
	n = 10,
	na.rm = FALSE,
	...
) {
	aroon_oscillator.default(
		x = x,
		cols = cols,
		n = n,
		na.rm = na.rm,
		...
	)
}


#' @usage NULL
#' @aliases aroon_oscillator
#'
#' @export
aroon_oscillator.plotly <- function(
	x,
	cols,
	n = 10,
	## splice:optional-plotly:start
	## splice:optional-plotly:end
	na.rm = FALSE,
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
		default = ~ high + low,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- aroon_oscillator(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		n = n
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
	name <- sprintf("AroonOsc(%d)", n)

	decorators <- list(
		function(p) add_limit(p, y_range = c(0, 100))
	)

	traces <- list(
		plotly_line(0, nrow(constructed_indicator)),
		list(y = ~AROONOSC, name = "AroonOscillator")
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
				"Aroon Oscillator"
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
