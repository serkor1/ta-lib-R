#' @export
#' @family Momentum Indicator
#'
#' @title Moving Average Convergence Divergence (Extended)
#' @templateVar .title Moving Average Convergence Divergence (Extended)
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun extended_moving_average_convergence_divergence
#' @templateVar .family Momentum Indicator
#' @templateVar .formula ~close
#'
## splice:documentation:start
#' @param fast ([list]). Period and Moving Average (MA) type for the fast MA. [EMA] by default.
#' @param slow ([list]). Period and Moving Average (MA) type for the slow MA. [EMA] by default.
#' @param signal ([list]). Period and Moving Average (MA) type for the signal MA. [EMA] by default.
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
	set_rownames(x, x_names)

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
	map_dfr(
		extended_moving_average_convergence_divergence.default(
			x = x,
			cols = cols,
			fast = fast,
			slow = slow,
			signal = signal,
			...
		)
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
	extended_moving_average_convergence_divergence.default(
		x = x,
		cols = cols,
		fast = fast,
		slow = slow,
		signal = signal,
		...
	)
}

#' @usage NULL
#' @aliases extended_moving_average_convergence_divergence
#'
#' @export
extended_moving_average_convergence_divergence.numeric <- function(
	x,
	cols,
	fast = EMA(n = 12),
	slow = EMA(n = 26),
	signal = EMA(n = 9),
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
	## to 'C'
	x <- .Call(
		"impl_ta_MACDEXT",
		## splice:numeric:start
		as.double(x),
		fast$n,
		fast$maType,
		slow$n,
		slow$maType,
		signal$n,
		signal$maType
		## splice:numeric:end
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
	constructed_indicator$direction <- constructed_indicator$MACDSignal >=
		constructed_indicator$MACD

	## generate plotly object
	## of the indicator
	chart_theme <- .chart_theme()

	## construct plotly object
	name <- sprintf(
		"MACD(%d, %d, %d)",
		if (is.list(fast)) fast$n else fast,
		if (is.list(slow)) slow$n else slow,
		if (is.list(signal)) signal$n else signal
	)

	traces <- list(
		list(
			y = ~MACDHist,
			color = ~direction,
			colors = c(
				chart_theme$bull_color,
				chart_theme$bear_color
			),
			type = 'bar',
			mode = NULL,
			showlegend = FALSE
		),
		list(
			y = ~MACDSignal,
			inherit = FALSE,
			name = sprintf(
				fmt = "Signal(%d)",
				if (is.list(signal)) signal$n else signal
			)
		),
		list(
			y = ~MACD,
			inherit = FALSE,
			name = sprintf(
				fmt = "MACD(%d, %d)",
				if (is.list(fast)) fast$n else fast,
				if (is.list(slow)) slow$n else slow
			)
		)
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
