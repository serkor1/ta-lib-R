#' @export
#' @family Momentum Indicators
#'
#' @title Aroon
#' @templateVar .title Aroon
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun aroon
#' @templateVar .family Momentum Indicators
#' @templateVar .formula ~high + low
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
#'
#' @template returns
aroon <- function(
	x,
	cols,
	timePeriod = 14,
	na.bridge = FALSE,
	...
) {
	UseMethod("aroon")
}

#' @export
#' @usage NULL
#' @rdname aroon
#'
#' @aliases aroon
AROON <- aroon

#' @usage NULL
#' @aliases aroon
#'
#' @export
aroon.default <- function(
	x,
	cols,
	timePeriod = 14,
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
		formula.default = ~ high + low,
		...
	)

	## extract rownames
	## for later attachment
	x_names <- index(constructed_series)

	## calculate indicator and
	## return as data.frame
	x <- .Call(
		C_impl_ta_AROON,
		constructed_series[[1]],
		constructed_series[[2]],
		as.integer(timePeriod),
		as.logical(na.bridge)
	)

	## readd rownames
	set_index(x, x_names)

	## return indicator
	x
}

#' @usage NULL
#' @aliases aroon
#'
#' @export
aroon.data.frame <- function(
	x,
	cols,
	timePeriod = 14,
	na.bridge = FALSE,
	...
) {
	as.data.frame(
		aroon.default(
			x = x,
			cols = cols,
			timePeriod = timePeriod,
			na.bridge = na.bridge,
			...
		)
	)
}

#' @usage NULL
#' @aliases aroon
#'
#' @export
aroon.matrix <- function(
	x,
	cols,
	timePeriod = 14,
	na.bridge = FALSE,
	...
) {
	as.matrix(
		aroon.default(
			x = x,
			cols = cols,
			timePeriod = timePeriod,
			na.bridge = na.bridge,
			...
		)
	)
}

#' @usage NULL
#' @aliases aroon
#'
#' @export
aroon.xts <- function(
	x,
	cols,
	timePeriod = 14,
	na.bridge = FALSE,
	...
) {
	assert_xts()

	as.xts(
		aroon.default(
			x = x,
			cols = cols,
			timePeriod = timePeriod,
			na.bridge = na.bridge,
			...
		)
	)
}

#' @usage NULL
AROON_lookback <- aroon_lookback <- function(
	x,
	cols,
	timePeriod = 14,
	na.bridge = FALSE,
	...
) {
	.Call(
		C_impl_ta_AROON_lookback,
		as.integer(timePeriod)
	)
}

#' @usage NULL
#' @aliases aroon
#'
#' @export
aroon.plotly <- function(
	x,
	cols,
	timePeriod = 14,
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
		formula.default = ~ high + low,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- aroon(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		timePeriod = timePeriod,
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
		"Aroon(%d)",
		timePeriod
	)

	decorators <- list(
		function(p) add_limit_ly(p, y_range = c(0, 100))
	)

	traces <- list(
		list(
			y = ~AroonDown,
			name = "AroonDown",
			legendgroup = name,
			legendgrouptitle = list(text = name)
		),

		list(
			y = ~AroonUp,
			name = "AroonUp",
			legendgroup = name,
			legendgrouptitle = list(text = name)
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
				"Aroon"
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
#' @aliases aroon
#'
#' @export
aroon.ggplot <- function(
	x,
	cols,
	timePeriod = 14,
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
		formula.default = ~ high + low,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- aroon(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		timePeriod = timePeriod,
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
	decorators <- list(
		function(p) add_limit_gg(p, c(0, 100))
	)
	layers <- list(
		list(y = "AroonDown", name = "AroonDown"),
		list(y = "AroonUp", name = "AroonUp")
	)
	name <- sprintf("Aroon(%d)", timePeriod)
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
				"Aroon"
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
