#' @export
#' @family Momentum Indicators
#'
#' @title Absolute Price Oscillator
#' @templateVar .title Absolute Price Oscillator
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun absolute_price_oscillator
#' @templateVar .family Momentum Indicators
#' @templateVar .formula ~close
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
#' @param fastPeriod ([integer]). Period of the fast MA. Defaults to `12`.
#' @param slowPeriod ([integer]). Period of the slow MA. Defaults to `26`.
#' @param maType ([integer]). Type of Moving Average. Defaults to `1` ([EMA]). Can also be passed as talib::EMA.
#' @template returns
absolute_price_oscillator <- function(
	x,
	cols,
	fastPeriod = 12,
	slowPeriod = 26,
	maType = 1,
	na.bridge = FALSE,
	...
) {
	UseMethod("absolute_price_oscillator")
}

#' @export
#' @usage NULL
#' @rdname absolute_price_oscillator
#'
#' @aliases absolute_price_oscillator
APO <- absolute_price_oscillator

#' @export
#' @usage NULL
#' @rdname absolute_price_oscillator
#'
#' @aliases absolute_price_oscillator
absolutePriceOscillator <- absolute_price_oscillator

#' @usage NULL
#' @aliases absolute_price_oscillator
#'
#' @export
absolute_price_oscillator.default <- function(
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
		formula.default = ~close,
		...
	)

	## extract rownames
	## for later attachment
	x_names <- index(constructed_series)

	## calculate indicator and
	## return as data.frame
	x <- .Call(
		C_impl_ta_APO,
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
#' @aliases absolute_price_oscillator
#'
#' @export
absolute_price_oscillator.data.frame <- function(
	x,
	cols,
	fastPeriod = 12,
	slowPeriod = 26,
	maType = 1,
	na.bridge = FALSE,
	...
) {
	as.data.frame(
		absolute_price_oscillator.default(
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
#' @aliases absolute_price_oscillator
#'
#' @export
absolute_price_oscillator.matrix <- function(
	x,
	cols,
	fastPeriod = 12,
	slowPeriod = 26,
	maType = 1,
	na.bridge = FALSE,
	...
) {
	as.matrix(
		absolute_price_oscillator.default(
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
#' @aliases absolute_price_oscillator
#'
#' @export
absolute_price_oscillator.xts <- function(
	x,
	cols,
	fastPeriod = 12,
	slowPeriod = 26,
	maType = 1,
	na.bridge = FALSE,
	...
) {
	as.xts(
		absolute_price_oscillator.default(
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
APO_lookback <- absolutePriceOscillator_lookback <- absolute_price_oscillator_lookback <- function(
	x,
	cols,
	fastPeriod = 12,
	slowPeriod = 26,
	maType = 1,
	na.bridge = FALSE,
	...
) {
	.Call(
		C_impl_ta_APO_lookback,
		as.integer(fastPeriod),
		as.integer(slowPeriod),
		as.maType(maType)
	)
}

#' @usage NULL
#' @aliases absolute_price_oscillator
#'
#' @export
absolute_price_oscillator.numeric <- function(
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
		C_impl_ta_APO,
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
#' @aliases absolute_price_oscillator
#'
#' @export
absolute_price_oscillator.plotly <- function(
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
		formula.default = ~close,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- absolute_price_oscillator(
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
	name <- sprintf(
		"APO(%d, %d)",
		slowPeriod,
		fastPeriod
	)

	decorators <- list()

	traces <- list(
		plotly_line(0, nrow(constructed_indicator), TRUE),
		list(y = ~APO)
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
				"Absolute Price Oscillator"
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
#' @aliases absolute_price_oscillator
#'
#' @export
absolute_price_oscillator.ggplot <- function(
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
		formula.default = ~close,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- absolute_price_oscillator(
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
	layers <- list(
		ggplot_line(0),
		list(y = "APO")
	)
	name <- sprintf("APO(%d, %d)", slowPeriod, fastPeriod)
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
				"Absolute Price Oscillator"
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
