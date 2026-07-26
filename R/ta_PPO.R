#' @export
#' @family Momentum Indicators
#'
#' @title Percentage Price Oscillator
#' @templateVar .title Percentage Price Oscillator
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun percentage_price_oscillator
#' @templateVar .family Momentum Indicators
#' @templateVar .formula ~close
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
#' @template returns
percentage_price_oscillator <- function(
	x,
	cols,
	fastPeriod = 12,
	slowPeriod = 26,
	maType = 0,
	na.bridge = FALSE,
	...
) {
	UseMethod("percentage_price_oscillator")
}

#' @export
#' @usage NULL
#' @rdname percentage_price_oscillator
#'
#' @aliases percentage_price_oscillator
PPO <- percentage_price_oscillator

#' @usage NULL
#' @aliases percentage_price_oscillator
#'
#' @export
percentage_price_oscillator.default <- function(
	x,
	cols,
	fastPeriod = 12,
	slowPeriod = 26,
	maType = 0,
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
		C_impl_ta_PPO,
		constructed_series[[1]],
		as.integer(fastPeriod),
		as.integer(slowPeriod),
		as.integer(maType),
		as.logical(na.bridge)
	)

	## readd rownames
	set_rownames(x, x_names)

	## return indicator
	x
}

#' @usage NULL
#' @aliases percentage_price_oscillator
#'
#' @export
percentage_price_oscillator.data.frame <- function(
	x,
	cols,
	fastPeriod = 12,
	slowPeriod = 26,
	maType = 0,
	na.bridge = FALSE,
	...
) {
	map_dfr(
		percentage_price_oscillator.default(
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
#' @aliases percentage_price_oscillator
#'
#' @export
percentage_price_oscillator.matrix <- function(
	x,
	cols,
	fastPeriod = 12,
	slowPeriod = 26,
	maType = 0,
	na.bridge = FALSE,
	...
) {
	percentage_price_oscillator.default(
		x = x,
		cols = cols,
		fastPeriod = fastPeriod,
		slowPeriod = slowPeriod,
		maType = maType,
		na.bridge = na.bridge,
		...
	)
}

#' @usage NULL
percentage_price_oscillator_lookback <- function(
	x,
	cols,
	fastPeriod = 12,
	slowPeriod = 26,
	maType = 0,
	na.bridge = FALSE,
	...
) {
	.Call(
		C_impl_ta_PPO_lookback,
		as.integer(fastPeriod),
		as.integer(slowPeriod),
		as.integer(maType)
	)
}
#' @usage NULL
#' @aliases percentage_price_oscillator
#'
#' @export
percentage_price_oscillator.numeric <- function(
	x,
	cols,
	fastPeriod = 12,
	slowPeriod = 26,
	maType = 0,
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
		C_impl_ta_PPO,
		as.double(x),
		as.integer(fastPeriod),
		as.integer(slowPeriod),
		as.integer(maType),
		as.logical(na.bridge)
	)

	if (dim(x)[2] == 1L) {
		dim(x) <- NULL
	}

	x
}

#' @usage NULL
#' @aliases percentage_price_oscillator
#'
#' @export
percentage_price_oscillator.plotly <- function(
	x,
	cols,
	fastPeriod = 12,
	slowPeriod = 26,
	maType = 0,
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
	constructed_indicator <- percentage_price_oscillator(
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
		"PPO(%d, %d)",
		fastPeriod,
		slowPeriod
	)

	traces <- list(
		list(y = ~PPO)
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
				"Percentage Price Oscillator"
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
#' @aliases percentage_price_oscillator
#'
#' @export
percentage_price_oscillator.ggplot <- function(
	x,
	cols,
	fastPeriod = 12,
	slowPeriod = 26,
	maType = 0,
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
	constructed_indicator <- percentage_price_oscillator(
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
		list(y = "PPO")
	)
	name <- sprintf("PPO(%d, %d)", fastPeriod, slowPeriod)
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
				"Percentage Price Oscillator"
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
