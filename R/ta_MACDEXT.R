#' @export
#' @family Momentum Indicators
#'
#' @title MACD with controllable MA type
#' @templateVar .title MACD with controllable MA type
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun extended_moving_average_convergence_divergence
#' @templateVar .family Momentum Indicators
#' @templateVar .formula ~close
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
#' @param fastPeriod ([integer]). Period of the fast MA. Defaults to `12`.
#' @param fastMa ([integer]). Type of Moving Average for fast MA. Defaults to `0` ([SMA]). Can also be passed as talib::SMA.
#' @param slowPeriod ([integer]). Period of the slow MA. Defaults to `26`.
#' @param slowMa ([integer]). Type of Moving Average for slow MA. Defaults to `0` ([SMA]). Can also be passed as talib::SMA.
#' @param signalPeriod ([integer]). Smoothing for the signal line (period length). Defaults to `9`.
#' @param signalMa ([integer]). Type of Moving Average for signal line. Defaults to `0` ([SMA]). Can also be passed as talib::SMA.
#' @template returns
extended_moving_average_convergence_divergence <- function(
	x,
	cols,
	fastPeriod = 12,
	fastMa = 0,
	slowPeriod = 26,
	slowMa = 0,
	signalPeriod = 9,
	signalMa = 0,
	na.bridge = FALSE,
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

#' @export
#' @usage NULL
#' @rdname extended_moving_average_convergence_divergence
#'
#' @aliases extended_moving_average_convergence_divergence
extendedMovingAverageConvergenceDivergence <- extended_moving_average_convergence_divergence

#' @usage NULL
#' @aliases extended_moving_average_convergence_divergence
#'
#' @export
extended_moving_average_convergence_divergence.default <- function(
	x,
	cols,
	fastPeriod = 12,
	fastMa = 0,
	slowPeriod = 26,
	slowMa = 0,
	signalPeriod = 9,
	signalMa = 0,
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
		default_formula = ~close,
		data = x,
		...
	)

	## extract rownames
	## for later attachment
	x_names <- rownames(constructed_series)

	## calculate indicator and
	## return as data.frame
	x <- .Call(
		C_impl_ta_MACDEXT,
		constructed_series[[1]],
		as.integer(fastPeriod),
		as.maType(fastMa),
		as.integer(slowPeriod),
		as.maType(slowMa),
		as.integer(signalPeriod),
		as.maType(signalMa),
		as.logical(na.bridge)
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
	fastPeriod = 12,
	fastMa = 0,
	slowPeriod = 26,
	slowMa = 0,
	signalPeriod = 9,
	signalMa = 0,
	na.bridge = FALSE,
	...
) {
	map_dfr(
		extended_moving_average_convergence_divergence.default(
			x = x,
			cols = cols,
			fastPeriod = fastPeriod,
			fastMa = fastMa,
			slowPeriod = slowPeriod,
			slowMa = slowMa,
			signalPeriod = signalPeriod,
			signalMa = signalMa,
			na.bridge = na.bridge,
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
	fastPeriod = 12,
	fastMa = 0,
	slowPeriod = 26,
	slowMa = 0,
	signalPeriod = 9,
	signalMa = 0,
	na.bridge = FALSE,
	...
) {
	extended_moving_average_convergence_divergence.default(
		x = x,
		cols = cols,
		fastPeriod = fastPeriod,
		fastMa = fastMa,
		slowPeriod = slowPeriod,
		slowMa = slowMa,
		signalPeriod = signalPeriod,
		signalMa = signalMa,
		na.bridge = na.bridge,
		...
	)
}

#' @usage NULL
MACDEXT_lookback <- extendedMovingAverageConvergenceDivergence_lookback <- extended_moving_average_convergence_divergence_lookback <- function(
	x,
	cols,
	fastPeriod = 12,
	fastMa = 0,
	slowPeriod = 26,
	slowMa = 0,
	signalPeriod = 9,
	signalMa = 0,
	na.bridge = FALSE,
	...
) {
	.Call(
		C_impl_ta_MACDEXT_lookback,
		as.integer(fastPeriod),
		as.maType(fastMa),
		as.integer(slowPeriod),
		as.maType(slowMa),
		as.integer(signalPeriod),
		as.maType(signalMa)
	)
}

#' @usage NULL
#' @aliases extended_moving_average_convergence_divergence
#'
#' @export
extended_moving_average_convergence_divergence.numeric <- function(
	x,
	cols,
	fastPeriod = 12,
	fastMa = 0,
	slowPeriod = 26,
	slowMa = 0,
	signalPeriod = 9,
	signalMa = 0,
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
		C_impl_ta_MACDEXT,
		as.double(x),
		as.integer(fastPeriod),
		as.maType(fastMa),
		as.integer(slowPeriod),
		as.maType(slowMa),
		as.integer(signalPeriod),
		as.maType(signalMa),
		as.logical(na.bridge)
	)

	if (dim(x)[2] == 1L) {
		dim(x) <- NULL
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
	fastPeriod = 12,
	fastMa = 0,
	slowPeriod = 26,
	slowMa = 0,
	signalPeriod = 9,
	signalMa = 0,
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
		default_formula = ~close,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- extended_moving_average_convergence_divergence(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		fastPeriod = fastPeriod,
		fastMa = fastMa,
		slowPeriod = slowPeriod,
		slowMa = slowMa,
		signalPeriod = signalPeriod,
		signalMa = signalMa,
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
		"MACD(%d, %d, %d)",
		fastPeriod,
		slowPeriod,
		signalPeriod
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
				signalPeriod
			)
		),
		list(
			y = ~MACD,
			inherit = FALSE,
			name = sprintf(
				fmt = "MACD(%d, %d)",
				fastPeriod,
				slowPeriod
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
				"MACD with controllable MA type"
			} else {
				title
			}
		),
		data = constructed_indicator[, values_to_extract, drop = FALSE],
		values_to_extract = values_to_extract,
		name = get0(x = "name", ifnotfound = NULL)
	)

	state <- .chart_state()
	state$sub <- c(state$sub, list(plotly_object))

	plotly_object
}

#' @usage NULL
#' @aliases extended_moving_average_convergence_divergence
#'
#' @export
extended_moving_average_convergence_divergence.ggplot <- function(
	x,
	cols,
	fastPeriod = 12,
	fastMa = 0,
	slowPeriod = 26,
	slowMa = 0,
	signalPeriod = 9,
	signalMa = 0,
	na.bridge = FALSE,
	title,
	## splice:optional-ggplot:start
	## splice:optional-ggplot:end
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
		default_formula = ~close,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- extended_moving_average_convergence_divergence(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		fastPeriod = fastPeriod,
		fastMa = fastMa,
		slowPeriod = slowPeriod,
		slowMa = slowMa,
		signalPeriod = signalPeriod,
		signalMa = signalMa,
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
	## calculate directions for bull
	## and bear candles
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
		list(y = "MACDSignal", name = sprintf("Signal(%d)", signalPeriod)),
		list(y = "MACD", name = sprintf("MACD(%d, %d)", fastPeriod, slowPeriod))
	)
	name <- sprintf("MACD(%d, %d, %d)", fastPeriod, slowPeriod, signalPeriod)
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
				"MACD with controllable MA type"
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
