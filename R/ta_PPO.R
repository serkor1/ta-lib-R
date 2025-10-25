#' @export
#' @family Momentum Indicator
#'
#' @title Percentage Price Oscillator
#' @templateVar .title Percentage Price Oscillator
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun percentage_price_oscillator
#'
## splice:documentation:start
#' @param fast Number of period for the fast MA
#' @param slow Number of period for the slow MA
#' @param ma Type of Moving Average
## splice:documentation:end
#'
#' @template description
percentage_price_oscillator <- function(
	x,
	cols,
	fast = 7,
	slow = 14,
	ma = SMA(n = 10),
	...
) {
	UseMethod("percentage_price_oscillator")
}

#' @export
#' @usage NULL
#' @rdname percentage_price_oscillator
#'
#' @aliases percentage_price_oscillator
PPO <- percentage_price_oscillator

#' @usage NULL
#' @aliases percentage_price_oscillator
#'
#' @export
percentage_price_oscillator.default <- function(
	x,
	cols,
	fast = 7,
	slow = 14,
	ma = SMA(n = 10),
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
		default = ~close,
		data = x,
		...
	)

	## extract rownames
	## for later attachment
	x_names <- rownames(constructed_series)

	## calculate indicator and
	## return as data.frame
	x <- .Call(
		"impl_ta_PPO",
		## splice:call:start
		constructed_series[[1]],
		as.integer(fast),
		as.integer(slow),
		ma$maType
		## splice:call:end
	)

	## readd rownames
	rownames(x) <- x_names

	## return indicator
	x
}

#' @usage NULL
#' @aliases percentage_price_oscillator
#'
#' @export
percentage_price_oscillator.data.frame <- function(
	x,
	cols,
	fast = 7,
	slow = 14,
	ma = SMA(n = 10),
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases percentage_price_oscillator
#'
#' @export
percentage_price_oscillator.matrix <- function(
	x,
	cols,
	fast = 7,
	slow = 14,
	ma = SMA(n = 10),
	...
) {
	as.matrix(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases percentage_price_oscillator
#'
#' @export
percentage_price_oscillator.plotly <- function(
	x,
	cols,
	fast = 7,
	slow = 14,
	ma = SMA(n = 10),
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
		default = ~close,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- percentage_price_oscillator(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		fast = fast,
		slow = slow,
		ma = ma
	)

	## add conditional idx
	constructed_indicator[["idx"]] <- add_idx(
		constructed_series
	)

	## construct {plotly}-object
	## splice:plotly-assembly:start
	plotly_object <- subchart(
		data = constructed_indicator,
		y = ~PPO,
		type = "scatter",
		mode = "lines",
		showlegend = FALSE
	)

	if (main_chart_exists()) {
		plotly_object <- add_title(
			x = plotly_object,
			text = "Percentage Price Oscillator"
		)
	}

	.plotting_environment$sub <- c(
		.plotting_environment$sub,
		list(plotly_object)
	)
	## splice:plotly-assembly:end

	plotly_object
}
