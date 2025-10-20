#' @export
#' @family Volume Indicator
#'
#' @title Chaikin A/D Oscillator
#' @templateVar .title Chaikin A/D Oscillator
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun chaikin_AD_oscillator
#'
#'
## input start
#' @param fast An <[integer]> of [length] 1. The window size passed into the fast moving average (MA).
#' @param slow An <[integer]> of [length] 1. The window size passed into the slow moving average (MA).
#'
#' @returns
#' A [data.frame]- or [matrix]-object:
#'
#' \describe{
#'  \item{ADOSC <[double]>}{Chaikin A/D Oscillator}
#' }
#'
## input end
#'
#' @template description
chaikin_AD_oscillator <- function(
	x,
	cols,
	fast = 3,
	slow = 10,
	...
) {
	UseMethod("chaikin_AD_oscillator")
}

#' @export
#' @usage NULL
#' @rdname chaikin_AD_oscillator
#'
#' @aliases chaikin_AD_oscillator
ADOSC <- chaikin_AD_oscillator

#' @usage NULL
#' @aliases chaikin_AD_oscillator
#'
#' @export
chaikin_AD_oscillator.default <- function(
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

	## extract rownames
	## for later attachment
	x_names <- rownames(x)

	## construct series
	## from input
	constructed_series <- series(
		x = cols,
		default = ~ high + low + close + volume,
		data = x,
		...
	)

	## calculate indicator and
	## return as data.frame
	x <- .Call(
		"impl_ta_ADOSC",
		## input start
		constructed_series[[1]],
		constructed_series[[2]],
		constructed_series[[3]],
		constructed_series[[4]],
		as.integer(fast),
		as.integer(slow)
		## input end
	)

	## readd rownames
	rownames(x) <- x_names

	## return indicator
	x
}

#' @usage NULL
#' @aliases chaikin_AD_oscillator
#'
#' @export
chaikin_AD_oscillator.data.frame <- function(
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
#' @aliases chaikin_AD_oscillator
#'
#' @export
chaikin_AD_oscillator.matrix <- function(
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
#' @aliases chaikin_AD_oscillator
#'
#' @export
chaikin_AD_oscillator.plotly <- function(
	x,
	cols,
	fast = 3,
	slow = 10,
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
	constructed_indicator <- chaikin_AD_oscillator(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		fast = 3,
		slow = 10
	)

	## add conditional idx
	constructed_indicator[["idx"]] <- add_idx(
		constructed_series
	)

	## construct {plotly}-object
	## input start
	plotly_object <- subchart(
		data = constructed_indicator,
		y = ~ADOSC,
		type = "scatter",
		mode = "lines",
		name = "AD",
		legendgroup = "ChaikinOscillator",
		showlegend = FALSE
	)

	plotly_object <- plotly::add_lines(
		p = plotly_object,
		x = constructed_indicator$idx,
		y = 0,
		line = list(
			dash = "dot"
		),
		showlegend = FALSE,
		hoverinfo = "skip",
		legendgroup = "ChaikinOscillator",
		name = "Zero"
	)

	if (main_chart_exists()) {
		plotly_object <- add_title(
			x = plotly_object,
			text = "Chaikin A/D Oscillator"
		)
	}

	.plotting_environment$sub <- c(
		.plotting_environment$sub,
		list(plotly_object)
	)
	## input end

	plotly_object
}
