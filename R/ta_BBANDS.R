#' @export
#' @family Overlap Studies
#'
#' @title Bollinger Bands
#' @templateVar .title Bollinger Bands
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun bollinger_bands
#' @templateVar .family Overlap Studies
#' @templateVar .formula ~close
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
#' @param deviationsUp ([double]). Deviation multiplier for upper band. Defaults to `2`.
#' @param deviationsDown ([double]). Deviation multiplier for lower band. Defaults to `2`.
#' @param maType ([integer]). Type of Moving Average. Defaults to `0` ([SMA]). Can also be passed as talib::SMA.
#' @template returns
bollinger_bands <- function(
	x,
	cols,
	timePeriod = 5,
	deviationsUp = 2,
	deviationsDown = 2,
	maType = 0,
	na.bridge = FALSE,
	...) {
  UseMethod("bollinger_bands")
}

#' @export
#' @usage NULL
#' @rdname bollinger_bands
#'
#' @aliases bollinger_bands
BBANDS <- bollinger_bands

#' @usage NULL
#' @aliases bollinger_bands
#'
#' @export
bollinger_bands.default <- function(
	x,
	cols,
	timePeriod = 5,
	deviationsUp = 2,
	deviationsDown = 2,
	maType = 0,
	na.bridge = FALSE,
	...) {

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
		C_impl_ta_BBANDS,
		constructed_series[[1]],
		as.integer(timePeriod),
		as.double(deviationsUp),
		as.double(deviationsDown),
		as.maType(maType),		
		as.logical(na.bridge)
	)

	## readd rownames
	set_rownames(x, x_names)

	## return indicator
	x
}

#' @usage NULL
#' @aliases bollinger_bands
#'
#' @export
bollinger_bands.data.frame <- function(
	x,
	cols,
	timePeriod = 5,
	deviationsUp = 2,
	deviationsDown = 2,
	maType = 0,
	na.bridge = FALSE,
	...
) {
	map_dfr(
		bollinger_bands.default(
			x = x,
			cols = cols,
			timePeriod = timePeriod,
			deviationsUp = deviationsUp,
			deviationsDown = deviationsDown,
			maType = maType,
			na.bridge = na.bridge,
			...
		)
	)

}

#' @usage NULL
#' @aliases bollinger_bands
#'
#' @export
bollinger_bands.matrix <- function(
	x,
	cols,
	timePeriod = 5,
	deviationsUp = 2,
	deviationsDown = 2,
	maType = 0,
	na.bridge = FALSE,
	...) {

	bollinger_bands.default(
			x = x,
			cols = cols ,
			timePeriod = timePeriod,
			deviationsUp = deviationsUp,
			deviationsDown = deviationsDown,
			maType = maType,
			na.bridge = na.bridge,
			...
		)
}

#' @usage NULL
BBANDS_lookback <- bollinger_bands_lookback <- function(
	x,
	cols,
	timePeriod = 5,
	deviationsUp = 2,
	deviationsDown = 2,
	maType = 0,
	na.bridge = FALSE,
	...
) {

	.Call(
		C_impl_ta_BBANDS_lookback,
		as.integer(timePeriod),
		as.double(deviationsUp),
		as.double(deviationsDown),
		as.maType(maType)
	)

}

#' @usage NULL
#' @aliases bollinger_bands
#'
#' @export
bollinger_bands.numeric <- function(
	x,
	cols,
	timePeriod = 5,
	deviationsUp = 2,
	deviationsDown = 2,
	maType = 0,
	na.bridge = FALSE,
	...) {

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
		C_impl_ta_BBANDS,
		as.double(x),
		as.integer(timePeriod),
		as.double(deviationsUp),
		as.double(deviationsDown),
		as.maType(maType),
		as.logical(na.bridge)
	)

	if (dim(x)[2] == 1L) {
		dim(x) <- NULL
	}

	x
}

#' @usage NULL
#' @aliases bollinger_bands
#'
#' @export
bollinger_bands.plotly <- function(
	x,
	cols,
	timePeriod = 5,
	deviationsUp = 2,
	deviationsDown = 2,
	maType = 0,
	na.bridge = FALSE,
	## splice:optional-plotly:start
	color = "steelblue",
	alpha = 0.2,
	## splice:optional-plotly:end
	...) {

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
	constructed_indicator <- bollinger_bands(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		timePeriod = timePeriod,
			deviationsUp = deviationsUp,
			deviationsDown = deviationsDown,
			maType = maType,
		na.bridge = TRUE
	)

	## add conditional idx
	constructed_indicator[["idx"]] <- add_idx(
		constructed_series
	)

	## construct {plotly}-object
	## splice:plotly-assembly:start

	## standard deviations
	sd_down <- as.double(deviationsDown)
	sd_up <- as.double(deviationsUp)

	if (sd_down == sd_up) {
		name <- label(
			"Bollinger Bands",
			timePeriod,
			sd_up
		)
	} else {
		name <- label(
			"Bollinger Bands",
			timePeriod,
			sd_up,
			sd_down
		)
	}

	traces <- list(
		list(
			y = ~UpperBand,
			name = paste("Upper Bollinger Band", paste0("+", sd_up, " sd")),
			showlegend = FALSE
		),
		list(
			y = ~MiddleBand,
			name = c(
				"SMA",
				"EMA",
				"WMA",
				"DEMA",
				"TEMA",
				"TRIMA",
				"KAMA",
				"MAMA",
				"T3"
			)[maType + 1],
			fill = "tonexty"
		),
		list(
			y = ~LowerBand,
			name = paste("Lower Bollinger Band", paste0("-", sd_down, " sd")),
			fill = "tonexty",
			showlegend = FALSE
		)
	)

	traces <- modify_traces(
		traces,
		fillcolor = plotly::toRGB(
			color,
			alpha
		),
		line = list(
			color = color
		)
	)
	## splice:plotly-assembly:end

	state <- .chart_state()
	plotly_object <- build_plotly(
		init = state[["main"]],
		traces = traces,
		decorators = list(),
		name = get0(
			x = "name",
			ifnotfound = NULL
		),
		data = constructed_indicator
	)
	state[["main"]] <- plotly_object

	plotly_object
}

#' @usage NULL
#' @aliases bollinger_bands
#'
#' @export
bollinger_bands.ggplot <- function(
	x,
	cols,
	timePeriod = 5,
	deviationsUp = 2,
	deviationsDown = 2,
	maType = 0,
	na.bridge = FALSE,
	## splice:optional-ggplot:start
	## splice:optional-ggplot:end
	...) {

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
	constructed_indicator <- bollinger_bands(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		timePeriod = timePeriod,
			deviationsUp = deviationsUp,
			deviationsDown = deviationsDown,
			maType = maType,
		na.bridge = TRUE
	)

	## add conditional idx
	constructed_indicator[["idx"]] <- add_idx(
		constructed_series
	)

	## construct {ggplot2}-object
	## splice:ggplot-assembly:start
	layers <- list(
		list(y = "UpperBand"),
		list(y = "MiddleBand"),
		list(y = "LowerBand"),
		list(
			geom = "ribbon",
			y = "MiddleBand",
			y_upper = "UpperBand",
			y_lower = "LowerBand"
		)
	)
	name <- label("Bollinger Bands", timePeriod, deviationsUp)
	## splice:ggplot-assembly:end

	state <- .chart_state()
	ggplot_object <- build_ggplot(
		init = state[["main"]],
		layers = layers,
		decorators = list(),
		name = get0(
			x = "name",
			ifnotfound = NULL
		),
		data = constructed_indicator
	)
	state[["main"]] <- ggplot_object

	ggplot_object
}
