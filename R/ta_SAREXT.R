#' @export
#' @family Overlap Studies
#'
#' @title Parabolic SAR - Extended
#' @templateVar .title Parabolic SAR - Extended
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun extended_parabolic_stop_and_reverse
#' @templateVar .family Overlap Studies
#' @templateVar .formula ~high + low
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
#' @param startValue ([double]). Start value and direction. 0 for Auto, >0 for Long, <0 for Short. Defaults to `0`.
#' @param offsetOnReverse ([double]). Percent offset added/removed to initial stop on short/long reversal. Defaults to `0`.
#' @param afInitLong ([double]). Acceleration Factor initial value for the Long direction. Defaults to `0.02`.
#' @param afLong ([double]). Acceleration Factor for the Long direction. Defaults to `0.02`.
#' @param afMaxLong ([double]). Acceleration Factor maximum value for the Long direction. Defaults to `0.2`.
#' @param afInitShort ([double]). Acceleration Factor initial value for the Short direction. Defaults to `0.02`.
#' @param afShort ([double]). Acceleration Factor for the Short direction. Defaults to `0.02`.
#' @param afMaxShort ([double]). Acceleration Factor maximum value for the Short direction. Defaults to `0.2`.
#' @template returns
extended_parabolic_stop_and_reverse <- function(
	x,
	cols,
	startValue = 0,
	offsetOnReverse = 0,
	afInitLong = 0.02,
	afLong = 0.02,
	afMaxLong = 0.2,
	afInitShort = 0.02,
	afShort = 0.02,
	afMaxShort = 0.2,
	na.bridge = FALSE,
	...
) {
	UseMethod("extended_parabolic_stop_and_reverse")
}

#' @export
#' @usage NULL
#' @rdname extended_parabolic_stop_and_reverse
#'
#' @aliases extended_parabolic_stop_and_reverse
SAREXT <- extended_parabolic_stop_and_reverse

#' @export
#' @usage NULL
#' @rdname extended_parabolic_stop_and_reverse
#'
#' @aliases extended_parabolic_stop_and_reverse
extendedParabolicStopAndReverse <- extended_parabolic_stop_and_reverse

#' @usage NULL
#' @aliases extended_parabolic_stop_and_reverse
#'
#' @export
extended_parabolic_stop_and_reverse.default <- function(
	x,
	cols,
	startValue = 0,
	offsetOnReverse = 0,
	afInitLong = 0.02,
	afLong = 0.02,
	afMaxLong = 0.2,
	afInitShort = 0.02,
	afShort = 0.02,
	afMaxShort = 0.2,
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
		C_impl_ta_SAREXT,
		constructed_series[[1]],
		constructed_series[[2]],
		as.double(startValue),
		as.double(offsetOnReverse),
		as.double(afInitLong),
		as.double(afLong),
		as.double(afMaxLong),
		as.double(afInitShort),
		as.double(afShort),
		as.double(afMaxShort),
		as.logical(na.bridge)
	)

	## readd rownames
	set_index(x, x_names)

	## return indicator
	x
}

#' @usage NULL
#' @aliases extended_parabolic_stop_and_reverse
#'
#' @export
extended_parabolic_stop_and_reverse.data.frame <- function(
	x,
	cols,
	startValue = 0,
	offsetOnReverse = 0,
	afInitLong = 0.02,
	afLong = 0.02,
	afMaxLong = 0.2,
	afInitShort = 0.02,
	afShort = 0.02,
	afMaxShort = 0.2,
	na.bridge = FALSE,
	...
) {
	as.data.frame(
		extended_parabolic_stop_and_reverse.default(
			x = x,
			cols = cols,
			startValue = startValue,
			offsetOnReverse = offsetOnReverse,
			afInitLong = afInitLong,
			afLong = afLong,
			afMaxLong = afMaxLong,
			afInitShort = afInitShort,
			afShort = afShort,
			afMaxShort = afMaxShort,
			na.bridge = na.bridge,
			...
		)
	)
}

#' @usage NULL
#' @aliases extended_parabolic_stop_and_reverse
#'
#' @export
extended_parabolic_stop_and_reverse.matrix <- function(
	x,
	cols,
	startValue = 0,
	offsetOnReverse = 0,
	afInitLong = 0.02,
	afLong = 0.02,
	afMaxLong = 0.2,
	afInitShort = 0.02,
	afShort = 0.02,
	afMaxShort = 0.2,
	na.bridge = FALSE,
	...
) {
	as.matrix(
		extended_parabolic_stop_and_reverse.default(
			x = x,
			cols = cols,
			startValue = startValue,
			offsetOnReverse = offsetOnReverse,
			afInitLong = afInitLong,
			afLong = afLong,
			afMaxLong = afMaxLong,
			afInitShort = afInitShort,
			afShort = afShort,
			afMaxShort = afMaxShort,
			na.bridge = na.bridge,
			...
		)
	)
}

#' @usage NULL
#' @aliases extended_parabolic_stop_and_reverse
#'
#' @export
extended_parabolic_stop_and_reverse.xts <- function(
	x,
	cols,
	startValue = 0,
	offsetOnReverse = 0,
	afInitLong = 0.02,
	afLong = 0.02,
	afMaxLong = 0.2,
	afInitShort = 0.02,
	afShort = 0.02,
	afMaxShort = 0.2,
	na.bridge = FALSE,
	...
) {
	as.xts(
		extended_parabolic_stop_and_reverse.default(
			x = x,
			cols = cols,
			startValue = startValue,
			offsetOnReverse = offsetOnReverse,
			afInitLong = afInitLong,
			afLong = afLong,
			afMaxLong = afMaxLong,
			afInitShort = afInitShort,
			afShort = afShort,
			afMaxShort = afMaxShort,
			na.bridge = na.bridge,
			...
		)
	)
}

#' @usage NULL
SAREXT_lookback <- extendedParabolicStopAndReverse_lookback <- extended_parabolic_stop_and_reverse_lookback <- function(
	x,
	cols,
	startValue = 0,
	offsetOnReverse = 0,
	afInitLong = 0.02,
	afLong = 0.02,
	afMaxLong = 0.2,
	afInitShort = 0.02,
	afShort = 0.02,
	afMaxShort = 0.2,
	na.bridge = FALSE,
	...
) {
	.Call(
		C_impl_ta_SAREXT_lookback,
		as.double(startValue),
		as.double(offsetOnReverse),
		as.double(afInitLong),
		as.double(afLong),
		as.double(afMaxLong),
		as.double(afInitShort),
		as.double(afShort),
		as.double(afMaxShort)
	)
}

#' @usage NULL
#' @aliases extended_parabolic_stop_and_reverse
#'
#' @export
extended_parabolic_stop_and_reverse.plotly <- function(
	x,
	cols,
	startValue = 0,
	offsetOnReverse = 0,
	afInitLong = 0.02,
	afLong = 0.02,
	afMaxLong = 0.2,
	afInitShort = 0.02,
	afShort = 0.02,
	afMaxShort = 0.2,
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
		formula.default = ~ high + low,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- extended_parabolic_stop_and_reverse(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		startValue = startValue,
		offsetOnReverse = offsetOnReverse,
		afInitLong = afInitLong,
		afLong = afLong,
		afMaxLong = afMaxLong,
		afInitShort = afInitShort,
		afShort = afShort,
		afMaxShort = afMaxShort,
		na.bridge = TRUE
	)

	## add conditional idx
	constructed_indicator[["idx"]] <- add_idx(
		constructed_series
	)

	## construct {plotly}-object
	## splice:plotly-assembly:start
	## identify bullish
	## signals
	bull <- (constructed_indicator$SAR[
		-c(1:attr(constructed_indicator, "lookback"))
	] <
		as.numeric(
			constructed_series[[2L]][
				-c(1:attr(constructed_indicator, "lookback"))
			]
		))
	## determine colors
	##
	colors <- ifelse(
		bull,
		plotly::toRGB(.chart_variables$bullish_body, alpha = 0.8),
		plotly::toRGB(.chart_variables$bearish_body, alpha = 0.8)
	)

	## constuct chart
	## element
	name <- "Parabolic Stop and Reverse (Extended)"
	traces <- list(
		list(
			y = ~SAREXT,
			type = "scatter",
			mode = "markers",
			color = colors,
			marker = list(
				size = 5,
				color = colors,
				line = list(
					color = "black",
					width = 0.75
				)
			)
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
#' @aliases extended_parabolic_stop_and_reverse
#'
#' @export
extended_parabolic_stop_and_reverse.ggplot <- function(
	x,
	cols,
	startValue = 0,
	offsetOnReverse = 0,
	afInitLong = 0.02,
	afLong = 0.02,
	afMaxLong = 0.2,
	afInitShort = 0.02,
	afShort = 0.02,
	afMaxShort = 0.2,
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
		formula.default = ~ high + low,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- extended_parabolic_stop_and_reverse(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		startValue = startValue,
		offsetOnReverse = offsetOnReverse,
		afInitLong = afInitLong,
		afLong = afLong,
		afMaxLong = afMaxLong,
		afInitShort = afInitShort,
		afShort = afShort,
		afMaxShort = afMaxShort,
		na.bridge = TRUE
	)

	## add conditional idx
	constructed_indicator[["idx"]] <- add_idx(
		constructed_series
	)

	## construct {ggplot2}-object
	## splice:ggplot-assembly:start
	layers <- list(
		list(y = "SAREXT", geom = "point")
	)
	name <- "SAR (Extended)"
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
