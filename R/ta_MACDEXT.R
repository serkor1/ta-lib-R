#' @export
#' @family Momentum Indicator
#'
#' @title Moving Average Convergence Divergence (Extended)
#' @templateVar .title Moving Average Convergence Divergence (Extended)
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun extended_moving_average_convergence_divergence
#'
## splice:documentation:start
#' @param fast Number of period for the fast MA.
#' @param slow Number of period for the slow MA.
#' @param signal Smoothing for the signal line.
## splice:documentation:end
#'
#' @template description
#' @template returns
extended_moving_average_convergence_divergence <- function(
	x,
	cols,
	fast = EMA(n = 12),
	slow = EMA(n = 26),
	signal = EMA(n = 9),
	...
) {
	UseMethod("extended_moving_average_convergence_divergence")
}

#' @export
#' @usage NULL
#' @rdname extended_moving_average_convergence_divergence
#'
#' @aliases extended_moving_average_convergence_divergence
MACDEXT <- extended_moving_average_convergence_divergence

#' @usage NULL
#' @aliases extended_moving_average_convergence_divergence
#'
#' @export
extended_moving_average_convergence_divergence.default <- function(
	x,
	cols,
	fast = EMA(n = 12),
	slow = EMA(n = 26),
	signal = EMA(n = 9),
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
		"impl_ta_MACDEXT",
		## splice:call:start
		constructed_series[[1]],
		fast$n,
		fast$maType,
		slow$n,
		slow$maType,
		signal$n,
		signal$maType
		## splice:call:end
	)

	## readd rownames
	rownames(x) <- x_names

	## return indicator
	x
}

#' @usage NULL
#' @aliases extended_moving_average_convergence_divergence
#'
#' @export
extended_moving_average_convergence_divergence.data.frame <- function(
	x,
	cols,
	fast = EMA(n = 12),
	slow = EMA(n = 26),
	signal = EMA(n = 9),
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases extended_moving_average_convergence_divergence
#'
#' @export
extended_moving_average_convergence_divergence.matrix <- function(
	x,
	cols,
	fast = EMA(n = 12),
	slow = EMA(n = 26),
	signal = EMA(n = 9),
	...
) {
	as.matrix(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases extended_moving_average_convergence_divergence
#'
#' @export
extended_moving_average_convergence_divergence.plotly <- function(
	x,
	cols,
	fast = EMA(n = 12),
	slow = EMA(n = 26),
	signal = EMA(n = 9),
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
	constructed_indicator <- extended_moving_average_convergence_divergence(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		fast = fast,
		slow = slow,
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
	constructed_indicator$direction <- constructed_indicator$signal >=
		constructed_indicator$macd

	## generate plotly object
	## of the indicator
	chart_theme <- .chart_theme()

	## construct plotly object
	plotly_object <- subchart(
		data = constructed_indicator,
		y = ~histogram,
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
		y = ~signal,
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
		y = ~macd,
		data = constructed_indicator,
		inherit = FALSE,
		name = sprintf(
			fmt = "MACD(%d, %d)",
			if (is.list(fast)) fast$n else fast,
			if (is.list(slow)) slow$n else slow
		)
	)

	if (!is.null(.plotting_environment$main)) {
		plotly_object <- add_title(
			x = plotly_object,
			text = sprintf(
				fmt = "MACD(%d, %d, %d)",
				if (is.list(fast)) fast$n else fast,
				if (is.list(slow)) slow$n else slow,
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
