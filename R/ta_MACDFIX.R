#' @export
#' @family Momentum Indicator
#'
#' @title Moving Average Convergence Divergence (Fixed)
#' @templateVar .title Moving Average Convergence Divergence (Fixed)
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun fixed_moving_average_convergence_divergence
#' @templateVar .family Momentum Indicator
#' @templateVar .formula ~close
#'
## splice:documentation:start
#' @param signal ([integer]). Period for the signal Moving Average (MA).
## splice:documentation:end
#'
#' @template description
#' @template returns
fixed_moving_average_convergence_divergence <- function(
	x,
	cols,
	signal = 9,
	na.bridge = FALSE,
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
	na.bridge = FALSE,
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
		C_impl_ta_MACDFIX,
		## splice:call:start
		constructed_series[[1]],
		as.integer(signal),
		## splice:call:end
		as.logical(na.bridge)
	)

	## readd rownames
	set_rownames(x, x_names)

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
	na.bridge = FALSE,
	...
) {
	map_dfr(
		fixed_moving_average_convergence_divergence.default(
			x = x,
			cols = cols,
			signal = signal,
			na.bridge = na.bridge,
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
	na.bridge = FALSE,
	...
) {
	fixed_moving_average_convergence_divergence.default(
		x = x,
		cols = cols,
		signal = signal,
		na.bridge = na.bridge,
		...
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
	na.bridge = FALSE,
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
		C_impl_ta_MACDFIX,
		## splice:numeric:start
		as.double(x),
		as.integer(signal),
		## splice:numeric:end
		as.logical(na.bridge)
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
	na.bridge = FALSE,
	## splice:optional-plotly:start
	## splice:optional-plotly:end
	title,
	...
) {
	## check that input value
	## 'x' is <plotly>-object
	assert_plotly_object(x)

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
		signal = signal,
		na.bridge = TRUE
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

	## construct plotly object
	name <- sprintf(
		"MACD(%d)",
		if (is.list(signal)) signal$n else signal
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
				12,
				26
			)
		)
	)
	## splice:plotly-assembly:end

	plotly_object <- add_last_value_ly(
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
				"Moving Average Convergence Divergence (Fixed)"
			} else {
				title
			}
		),
		data = constructed_indicator[, values_to_extract, drop = FALSE],
		values_to_extract = values_to_extract
	)

	state <- .chart_state()
	state$sub <- c(state$sub, list(plotly_object))

	plotly_object
}

#' @usage NULL
#' @aliases fixed_moving_average_convergence_divergence
#'
#' @export
fixed_moving_average_convergence_divergence.ggplot <- function(
	x,
	cols,
	signal = 9,
	na.bridge = FALSE,
	## splice:optional-ggplot:start
	## splice:optional-ggplot:end
	title,
	...
) {
	## check ggplot2 availability
	assert_ggplot2()

	## check that input value
	## 'cols' is a <formula>-objet
	if (!missing(cols)) {
		assert_formula(cols)
	}

	## construct series from
	## {ggplot}-object
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
		signal = signal,
		na.bridge = TRUE
	)

	## the constructed indicator
	## always returns expected
	## columns which can be passed
	## down to add_last_value_gg()
	values_to_extract <- colnames(constructed_indicator)

	## add conditional idx
	constructed_indicator[["idx"]] <- add_idx(
		constructed_series
	)

	## construct {ggplot2}-object
	## splice:ggplot-assembly:start
	constructed_indicator$direction <- constructed_indicator$MACDSignal >=
		constructed_indicator$MACD
	layers <- list(
		list(
			y = "MACDHist",
			geom = "bar",
			direction = "direction",
			colors = c(
				.chart_variables$bullish_body,
				.chart_variables$bearish_body
			)
		),
		list(
			y = "MACDSignal",
			name = sprintf(
				"Signal(%d)",
				if (is.list(signal)) signal$n else signal
			)
		),
		list(
			y = "MACD",
			name = sprintf("MACD(%d, %d)", 12, 26)
		)
	)
	name <- sprintf("MACD(%d)", if (is.list(signal)) signal$n else signal)
	## splice:ggplot-assembly:end

	ggplot_object <- add_last_value_gg(
		build_ggplot(
			init = ggplot_init(),
			layers = layers,
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
				"Moving Average Convergence Divergence (Fixed)"
			} else {
				title
			}
		),
		data = constructed_indicator[, values_to_extract, drop = FALSE],
		values_to_extract = values_to_extract,
		name = get0(x = "name", ifnotfound = NULL)
	)

	state <- .chart_state()
	state$sub <- c(state$sub, list(ggplot_object))

	ggplot_object
}
