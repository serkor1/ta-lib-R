#' @export
#' @family Cycle Indicator
#'
#' @title Hilbert Transform - SineWave
#' @templateVar .title Hilbert Transform - SineWave
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun sine_wave
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
sine_wave <- function(
	x,
	cols,
	...
) {
	UseMethod("sine_wave")
}

#' @export
#' @usage NULL
#' @rdname sine_wave
#'
#' @aliases sine_wave
HT_SINE <- sine_wave

#' @usage NULL
#' @aliases sine_wave
#'
#' @export
sine_wave.default <- function(
	x,
	cols,
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
	x_names <- rownames(x)

	## calculate indicator and
	## return as data.frame
	x <- .Call(
		"impl_ta_HT_SINE",
		## splice:call:start
		constructed_series[[1]]
		## splice:call:end
	)

	## readd rownames
	rownames(x) <- x_names

	## return indicator
	x
}

#' @usage NULL
#' @aliases sine_wave
#'
#' @export
sine_wave.data.frame <- function(
	x,
	cols,
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases sine_wave
#'
#' @export
sine_wave.matrix <- function(
	x,
	cols,
	...
) {
	as.matrix(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases sine_wave
#'
#' @export
sine_wave.plotly <- function(
	x,
	cols,
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
	constructed_indicator <- sine_wave(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		)
	)

	## add conditional idx
	constructed_indicator[["idx"]] <- add_idx(
		constructed_series
	)

	## construct {plotly}-object
	## splice:plotly-assembly:start
	plotly_object <- subchart(
		data = constructed_indicator,
		y = ~sine,
		type = "scatter",
		mode = "lines",
		name = "Sine",
		legendgroup = "sinewave"
	)

	plotly_object <- plotly::add_lines(
		p = plotly_object,
		x = ~idx,
		y = ~leadsine,
		data = constructed_indicator,
		name = "Lead Sine",
		legendgroup = "sinewave"
	)

	if (main_chart_exists()) {
		plotly_object <- add_title(
			x = plotly_object,
			text = "Sine Wave"
		)
	}

	.plotting_environment$sub <- c(
		.plotting_environment$sub,
		list(plotly_object)
	)
	## splice:plotly-assembly:end

	plotly_object
}
