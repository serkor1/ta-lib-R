#' @export
#' @family Overlap Studies
#'
#' @title Moving average with variable period
#' @templateVar .title Moving average with variable period
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun variable_moving_average_period
#' @templateVar .family Overlap Studies
#' @templateVar .formula ~close + periods
#'
## splice:documentation:start
#' @example man/examples/MAVP-example.R
## splice:documentation:end
#'
#' @template description
#' @param minimumPeriod ([integer]). Value less than minimum will be changed to Minimum period. Defaults to `2`.
#' @param maximumPeriod ([integer]). Value higher than maximum will be changed to Maximum period. Defaults to `30`.
#' @param maType ([integer]). Type of Moving Average. Defaults to `0` ([SMA]). Can also be passed as talib::SMA.
#' @template returns
variable_moving_average_period <- function(
	x,
	cols,
	minimumPeriod = 2,
	maximumPeriod = 30,
	maType = 0,
	na.bridge = FALSE,
	...
) {
	UseMethod("variable_moving_average_period")
}

#' @export
#' @usage NULL
#' @rdname variable_moving_average_period
#'
#' @aliases variable_moving_average_period
MAVP <- variable_moving_average_period

#' @usage NULL
#' @aliases variable_moving_average_period
#'
#' @export
variable_moving_average_period.default <- function(
	x,
	cols,
	minimumPeriod = 2,
	maximumPeriod = 30,
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
		default_formula = ~ close + periods,
		data = x,
		...
	)

	## extract rownames
	## for later attachment
	x_names <- rownames(constructed_series)

	## calculate indicator and
	## return as data.frame
	x <- .Call(
		C_impl_ta_MAVP,
		constructed_series[[1]],
		constructed_series[[2]],
		as.integer(minimumPeriod),
		as.integer(maximumPeriod),
		as.integer(maType),
		as.logical(na.bridge)
	)

	## readd rownames
	set_rownames(x, x_names)

	## return indicator
	x
}

#' @usage NULL
#' @aliases variable_moving_average_period
#'
#' @export
variable_moving_average_period.data.frame <- function(
	x,
	cols,
	minimumPeriod = 2,
	maximumPeriod = 30,
	maType = 0,
	na.bridge = FALSE,
	...
) {
	map_dfr(
		variable_moving_average_period.default(
			x = x,
			cols = cols,
			minimumPeriod = minimumPeriod,
			maximumPeriod = maximumPeriod,
			maType = maType,
			na.bridge = na.bridge,
			...
		)
	)
}

#' @usage NULL
#' @aliases variable_moving_average_period
#'
#' @export
variable_moving_average_period.matrix <- function(
	x,
	cols,
	minimumPeriod = 2,
	maximumPeriod = 30,
	maType = 0,
	na.bridge = FALSE,
	...
) {
	variable_moving_average_period.default(
		x = x,
		cols = cols,
		minimumPeriod = minimumPeriod,
		maximumPeriod = maximumPeriod,
		maType = maType,
		na.bridge = na.bridge,
		...
	)
}

#' @usage NULL
variable_moving_average_period_lookback <- function(
	x,
	cols,
	minimumPeriod = 2,
	maximumPeriod = 30,
	maType = 0,
	na.bridge = FALSE,
	...
) {
	.Call(
		C_impl_ta_MAVP_lookback,
		as.integer(minimumPeriod),
		as.integer(maximumPeriod),
		as.integer(maType)
	)
}
#' @usage NULL
#' @aliases variable_moving_average_period
#'
#' @export
variable_moving_average_period.plotly <- function(
	x,
	cols,
	minimumPeriod = 2,
	maximumPeriod = 30,
	maType = 0,
	na.bridge = FALSE,
	## splice:optional-plotly:start
	## splice:optional-plotly:end
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
		default_formula = ~ close + periods,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- variable_moving_average_period(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		minimumPeriod = minimumPeriod,
		maximumPeriod = maximumPeriod,
		maType = maType,
		na.bridge = TRUE
	)

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
	name <- sprintf(
		"MAVP(%d, %d, %s)",
		min(minimumPeriod, maximumPeriod),
		max(minimumPeriod, maximumPeriod),
		mapMaType(maType)
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
#' @aliases variable_moving_average_period
#'
#' @export
variable_moving_average_period.ggplot <- function(
	x,
	cols,
	minimumPeriod = 2,
	maximumPeriod = 30,
	maType = 0,
	na.bridge = FALSE,
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
		default_formula = ~ close + periods,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- variable_moving_average_period(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		minimumPeriod = minimumPeriod,
		maximumPeriod = maximumPeriod,
		maType = maType,
		na.bridge = TRUE
	)

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
	name <- "MAVP"
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
