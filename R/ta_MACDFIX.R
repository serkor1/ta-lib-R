#' @export
#' @family Momentum Indicator
#'
#' @title Moving Average Convergence Divergence (Fixed)
#' @templateVar .title Moving Average Convergence Divergence (Fixed)
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun fixed_moving_average_convergence_divergence
#'
## splice:documentation:start
#' @param signal Smoothing for the signal line.
## splice:documentation:end
#'
#' @template description
#' @template returns
fixed_moving_average_convergence_divergence <- function(
	x,
	cols,
	signal = 9,
	...
) {
	UseMethod("fixed_moving_average_convergence_divergence")
}

#' @export
#' @usage NULL
#' @rdname fixed_moving_average_convergence_divergence
#'
#' @aliases fixed_moving_average_convergence_divergence
MACDFIX <- fixed_moving_average_convergence_divergence

#' @usage NULL
#' @aliases fixed_moving_average_convergence_divergence
#'
#' @export
fixed_moving_average_convergence_divergence.default <- function(
	x,
	cols,
	signal = 9,
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
		"impl_ta_MACDFIX",
		## splice:call:start
		constructed_series[[1]],
		as.integer(signal)
		## splice:call:end
	)

	## readd rownames
	rownames(x) <- x_names

	## return indicator
	x
}

#' @usage NULL
#' @aliases fixed_moving_average_convergence_divergence
#'
#' @export
fixed_moving_average_convergence_divergence.data.frame <- function(
	x,
	cols,
	signal = 9,
	...
) {
	as.data.frame(
		fixed_moving_average_convergence_divergence.default(
			x = x,
			cols = cols,
			signal = signal,
			...
		)
	)
}

#' @usage NULL
#' @aliases fixed_moving_average_convergence_divergence
#'
#' @export
fixed_moving_average_convergence_divergence.matrix <- function(
	x,
	cols,
	signal = 9,
	...
) {
	as.matrix(
		fixed_moving_average_convergence_divergence.default(
			x = x,
			cols = cols,
			signal = signal,
			...
		)
	)
}

#' @usage NULL
#' @aliases fixed_moving_average_convergence_divergence
#'
#' @export
fixed_moving_average_convergence_divergence.numeric <- function(
	x,
	cols,
	signal = 9,
	...
) {
	## warn if 'cols' have been
	## passed just to make sure
	## the user knows its not possible
	## or relevant
	if (!missing(cols)) {
		warning("'cols' is passed but is unused for vectors.")
	}

	## pass the argument directly
	## to fixed_moving_average_convergence_divergence.default()
	x <- fixed_moving_average_convergence_divergence.default(
		x = x,
		cols = cols,
		,
		signal = signal,
		...
	)

	## check if it has 'dims'
	## and convert to double if
	## not to honor the 'type-safety'-esque
	## approach
	##
	## NOTE: this adds a few ns overhead but
	##       its a robust alternative to code it
	##       manually. Any suggestions are welcome
	if (is.null(dim(x))) {
		x <- as.double(x)
	}

	x
}

#' @usage NULL
#' @aliases fixed_moving_average_convergence_divergence
#'
#' @export
fixed_moving_average_convergence_divergence.plotly <- function(
	x,
	cols,
	signal = 9,
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
	constructed_indicator <- fixed_moving_average_convergence_divergence(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		signal = signal
	)

	## add conditional idx
	constructed_indicator[["idx"]] <- add_idx(
		constructed_series
	)

	## construct {plotly}-object
	## splice:plotly-assembly:start
	## calculate directions for bull
	## and bear candles
	constructed_indicator$direction <- constructed_indicator$MACDSignal >=
		constructed_indicator$MACD

	## generate plotly object
	## of the indicator
	chart_theme <- .chart_theme()

	## construct plotly object
	plotly_object <- subchart(
		data = constructed_indicator,
		y = ~MACDHist,
		color = ~direction,
		colors = c(
			chart_theme$bull_color,
			chart_theme$bear_color
		),
		type = 'bar',
		showlegend = FALSE
	)

	plotly_object <- plotly::add_lines(
		plotly_object,
		x = ~idx,
		y = ~MACDSignal,
		data = constructed_indicator,
		inherit = FALSE,
		name = sprintf(
			fmt = "Signal(%d)",
			if (is.list(signal)) signal$n else signal
		)
	)

	plotly_object <- plotly::add_lines(
		plotly_object,
		x = ~idx,
		y = ~MACD,
		data = constructed_indicator,
		inherit = FALSE,
		name = sprintf(
			fmt = "MACD(%d, %d)",
			12L,
			26L
		)
	)

	if (!is.null(.plotting_environment$main)) {
		plotly_object <- add_title(
			x = plotly_object,
			text = sprintf(
				fmt = "MACD(%d, %d, %d)",
				12L,
				26L,
				if (is.list(signal)) signal$n else signal
			)
		)
	}

	.plotting_environment$sub <- c(
		.plotting_environment$sub,
		list(plotly_object)
	)
	## splice:plotly-assembly:end

	plotly_object
}
