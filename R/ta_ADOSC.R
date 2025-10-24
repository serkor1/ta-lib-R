#' @export
#' @family Volume Indicator
#'
#' @title Chaikin A/D Oscillator
#' @templateVar .title Chaikin A/D Oscillator
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun chaikin_accumulation_distribution_oscillator
#'
## splice:documentation:start
#' @param fast Period for the fast MA
#' @param slow Period for the slow MA
## splice:documentation:end
#'
#' @template description
chaikin_accumulation_distribution_oscillator <- function(
	x,
	cols,
	fast = 3,
	slow = 10,
	...
) {
	UseMethod("chaikin_accumulation_distribution_oscillator")
}

#' @export
#' @usage NULL
#' @rdname chaikin_accumulation_distribution_oscillator
#'
#' @aliases chaikin_accumulation_distribution_oscillator
ADOSC <- chaikin_accumulation_distribution_oscillator

#' @usage NULL
#' @aliases chaikin_accumulation_distribution_oscillator
#'
#' @export
chaikin_accumulation_distribution_oscillator.default <- function(
	x,
	cols,
	fast = 3,
	slow = 10,
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
		default = ~ high + low + close + volume,
		data = x,
		...
	)

	## extract rownames
	## for later attachment
	x_names <- rownames(x)

	## calculate indicator and
	## return as data.frame
	x <- .Call(
		"impl_ta_ADOSC",
		## splice:call:start
		constructed_series[[1]],
		constructed_series[[2]],
		constructed_series[[3]],
		constructed_series[[4]],
		as.integer(fast),
		as.integer(slow)
		## splice:call:end
	)

	## readd rownames
	rownames(x) <- x_names

	## return indicator
	x
}

#' @usage NULL
#' @aliases chaikin_accumulation_distribution_oscillator
#'
#' @export
chaikin_accumulation_distribution_oscillator.data.frame <- function(
	x,
	cols,
	fast = 3,
	slow = 10,
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases chaikin_accumulation_distribution_oscillator
#'
#' @export
chaikin_accumulation_distribution_oscillator.matrix <- function(
	x,
	cols,
	fast = 3,
	slow = 10,
	...
) {
	as.matrix(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases chaikin_accumulation_distribution_oscillator
#'
#' @export
chaikin_accumulation_distribution_oscillator.plotly <- function(
	x,
	cols,
	fast = 3,
	slow = 10,
	## splice:optional-plotly:start
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
		default = ~ high + low + close + volume,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- chaikin_accumulation_distribution_oscillator(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		fast = fast,
		slow = slow
	)

	## add conditional idx
	constructed_indicator[["idx"]] <- add_idx(
		constructed_series
	)

	## construct {plotly}-object
	## splice:plotly-assembly:start
	plotly_object <- subchart(
		data = constructed_indicator,
		y = ~ADOSC,
		type = "scatter",
		mode = "lines",
		showlegend = FALSE
	)

	if (main_chart_exists()) {
		plotly_object <- add_title(
			x = plotly_object,
			text = "Chaikin A/D Line"
		)
	}

	.plotting_environment$sub <- c(
		.plotting_environment$sub,
		list(plotly_object)
	)
	## splice:plotly-assembly:end

	plotly_object
}
