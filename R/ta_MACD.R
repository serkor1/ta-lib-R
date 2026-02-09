#' @export
#' @family Momentum Indicator
#'
#' @title Moving Average Convergence Divergence
#' @templateVar .title Moving Average Convergence Divergence
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun moving_average_convergence_divergence
#' @templateVar .family Momentum Indicator
#' @templateVar .formula ~close
#'
## splice:documentation:start
#' @param fast ([integer]). Period for the fast Moving Average (MA).
#' @param slow ([integer]). Period for the slow Moving Average (MA).
#' @param signal ([integer]). Period for the signal Moving Average (MA).
## splice:documentation:end
#'
#' @template description
#' @template returns
moving_average_convergence_divergence <- function(
	x,
	cols,
	fast = 12,
	slow = 26,
	signal = 9,
	...
) {
	UseMethod("moving_average_convergence_divergence")
}

#' @export
#' @usage NULL
#' @rdname moving_average_convergence_divergence
#'
#' @aliases moving_average_convergence_divergence
MACD <- moving_average_convergence_divergence

#' @usage NULL
#' @aliases moving_average_convergence_divergence
#'
#' @export
moving_average_convergence_divergence.default <- function(
	x,
	cols,
	fast = 12,
	slow = 26,
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
		"impl_ta_MACD",
		## splice:call:start
		constructed_series[[1]],
		as.integer(fast),
		as.integer(slow),
		as.integer(signal)
		## splice:call:end
	)

	## readd rownames
	set_rownames(x, x_names)

	## return indicator
	x
}

#' @usage NULL
#' @aliases moving_average_convergence_divergence
#'
#' @export
moving_average_convergence_divergence.data.frame <- function(
	x,
	cols,
	fast = 12,
	slow = 26,
	signal = 9,
	...
) {
	map_dfr(
		moving_average_convergence_divergence.default(
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
#' @aliases moving_average_convergence_divergence
#'
#' @export
moving_average_convergence_divergence.matrix <- function(
	x,
	cols,
	fast = 12,
	slow = 26,
	signal = 9,
	...
) {
	moving_average_convergence_divergence.default(
		x = x,
		cols = cols,
		fast = fast,
		slow = slow,
		signal = signal,
		...
	)
}

#' @usage NULL
#' @aliases moving_average_convergence_divergence
#'
#' @export
moving_average_convergence_divergence.numeric <- function(
	x,
	cols,
	fast = 12,
	slow = 26,
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
	## to 'C'
	x <- .Call(
		"impl_ta_MACD",
		## splice:numeric:start
		as.double(x),
		as.integer(fast),
		as.integer(slow),
		as.integer(signal)
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
#' @aliases moving_average_convergence_divergence
#'
#' @export
moving_average_convergence_divergence.plotly <- function(
	x,
	cols,
	fast = 12,
	slow = 26,
	signal = 9,
	## splice:optional-plotly:start
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
		default = ~close,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- moving_average_convergence_divergence(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		fast = fast,
		slow = slow,
		signal = signal
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
		fast,
		slow,
		signal
	)

	traces <- list(
		list(
			y = ~MACDHist,
			color = ~direction,
			colors = c(
				.chart_variables$bullish_body,
				.chart_variables$bearish_body
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
				"Moving Average Convergence Divergence"
			} else {
				title
			}
		),
		data = constructed_indicator,
		values_to_extract = values_to_extract
	)

	.plotting_environment$sub <- c(
		.plotting_environment$sub,
		list(plotly_object)
	)

	plotly_object
}
