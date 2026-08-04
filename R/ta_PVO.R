#' @export
#' @family Volume Indicators
#'
#' @title Percentage Volume Oscillator
#' @templateVar .title Percentage Volume Oscillator
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun percentage_volume_oscillator
#' @templateVar .family Volume Indicators
#' @templateVar .formula ~volume
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
#' @param fastPeriod ([integer]). Period of the fast MA. Defaults to `12`.
#' @param slowPeriod ([integer]). Period of the slow MA. Defaults to `26`.
#' @param maType ([integer]). Type of Moving Average. Defaults to `1` ([EMA]). Can also be passed as talib::EMA.
#' @template returns
percentage_volume_oscillator <- function(
	x,
	cols,
	fastPeriod = 12,
	slowPeriod = 26,
	maType = 1,
	na.bridge = FALSE,
	...
) {
	UseMethod("percentage_volume_oscillator")
}

#' @export
#' @usage NULL
#' @rdname percentage_volume_oscillator
#'
#' @aliases percentage_volume_oscillator
PVO <- percentage_volume_oscillator

#' @export
#' @usage NULL
#' @rdname percentage_volume_oscillator
#'
#' @aliases percentage_volume_oscillator
percentageVolumeOscillator <- percentage_volume_oscillator

#' @usage NULL
#' @aliases percentage_volume_oscillator
#'
#' @export
percentage_volume_oscillator.default <- function(
	x,
	cols,
	fastPeriod = 12,
	slowPeriod = 26,
	maType = 1,
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
		x = x,
		formula = cols,
		formula.default = ~volume,
		...
	)

	## extract rownames
	## for later attachment
	x_names <- index(constructed_series)

	## calculate indicator and
	## return as data.frame
	x <- .Call(
		C_impl_ta_PVO,
		constructed_series[[1]],
		as.integer(fastPeriod),
		as.integer(slowPeriod),
		as.maType(maType),
		as.logical(na.bridge)
	)

	## readd rownames
	set_index(x, x_names)

	## return indicator
	x
}

#' @usage NULL
#' @aliases percentage_volume_oscillator
#'
#' @export
percentage_volume_oscillator.data.frame <- function(
	x,
	cols,
	fastPeriod = 12,
	slowPeriod = 26,
	maType = 1,
	na.bridge = FALSE,
	...
) {
	as.data.frame(
		percentage_volume_oscillator.default(
			x = x,
			cols = cols,
			fastPeriod = fastPeriod,
			slowPeriod = slowPeriod,
			maType = maType,
			na.bridge = na.bridge,
			...
		)
	)
}

#' @usage NULL
#' @aliases percentage_volume_oscillator
#'
#' @export
percentage_volume_oscillator.matrix <- function(
	x,
	cols,
	fastPeriod = 12,
	slowPeriod = 26,
	maType = 1,
	na.bridge = FALSE,
	...
) {
	as.matrix(
		percentage_volume_oscillator.default(
			x = x,
			cols = cols,
			fastPeriod = fastPeriod,
			slowPeriod = slowPeriod,
			maType = maType,
			na.bridge = na.bridge,
			...
		)
	)
}

#' @usage NULL
#' @aliases percentage_volume_oscillator
#'
#' @export
percentage_volume_oscillator.xts <- function(
	x,
	cols,
	fastPeriod = 12,
	slowPeriod = 26,
	maType = 1,
	na.bridge = FALSE,
	...
) {
	as.xts(
		percentage_volume_oscillator.default(
			x = x,
			cols = cols,
			fastPeriod = fastPeriod,
			slowPeriod = slowPeriod,
			maType = maType,
			na.bridge = na.bridge,
			...
		)
	)
}

#' @usage NULL
PVO_lookback <- percentageVolumeOscillator_lookback <- percentage_volume_oscillator_lookback <- function(
	x,
	cols,
	fastPeriod = 12,
	slowPeriod = 26,
	maType = 1,
	na.bridge = FALSE,
	...
) {
	.Call(
		C_impl_ta_PVO_lookback,
		as.integer(fastPeriod),
		as.integer(slowPeriod),
		as.maType(maType)
	)
}

#' @usage NULL
#' @aliases percentage_volume_oscillator
#'
#' @export
percentage_volume_oscillator.numeric <- function(
	x,
	cols,
	fastPeriod = 12,
	slowPeriod = 26,
	maType = 1,
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
		C_impl_ta_PVO,
		as.double(x),
		as.integer(fastPeriod),
		as.integer(slowPeriod),
		as.maType(maType),
		as.logical(na.bridge)
	)

	if (dim(x)[2] == 1L) {
		dim(x) <- NULL
	}

	x
}

#' @usage NULL
#' @aliases percentage_volume_oscillator
#'
#' @export
percentage_volume_oscillator.plotly <- function(
	x,
	cols,
	fastPeriod = 12,
	slowPeriod = 26,
	maType = 1,
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
		formula.default = ~volume,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- percentage_volume_oscillator(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		fastPeriod = fastPeriod,
		slowPeriod = slowPeriod,
		maType = maType,
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
	traces <- lapply(
		setdiff(colnames(constructed_indicator), "idx"),
		function(col) {
			list(
				y = stats::as.formula(
					paste0("~", col)
				),
				name = col
			)
		}
	)
	name <- "PVO"
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
				"Percentage Volume Oscillator"
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
#' @aliases percentage_volume_oscillator
#'
#' @export
percentage_volume_oscillator.ggplot <- function(
	x,
	cols,
	fastPeriod = 12,
	slowPeriod = 26,
	maType = 1,
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
		formula.default = ~volume,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- percentage_volume_oscillator(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		fastPeriod = fastPeriod,
		slowPeriod = slowPeriod,
		maType = maType,
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
	layers <- lapply(
		setdiff(colnames(constructed_indicator), "idx"),
		function(col) list(y = col)
	)
	name <- "PVO"
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
				"Percentage Volume Oscillator"
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
