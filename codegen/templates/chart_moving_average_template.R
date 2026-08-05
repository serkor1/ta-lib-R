#' @usage NULL
#' @aliases ${FUN}
#'
#' @export
${FUN}.${METHOD} <- function(
	x,
	${MA_SERIES}
	${ARGS}
	cols,
	na.bridge = FALSE,
	...) {

#plotly#	## check that input value
#plotly#	## 'x' is <plotly>-object
#plotly#	assert_plotly_object(x)
#ggplot#	## check ggplot2 availability
#ggplot#	assert_ggplot2()

	## check that input value
	## 'cols' is a <formula>-objet
	if (!missing(cols)) {
		assert_formula(cols)
	}

	## construct series from
	## {${METHOD}}-object
	constructed_series <- series(
		x = x,
		formula = cols,
		formula.default = ${MA_FORMULA},
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- ${FUN}(
		x = constructed_series,
		${MA_PSERIES}
		cols = rebuild_formula(
			names(constructed_series)
		),
		${PARGS}
		na.bridge = TRUE
	)

	## add conditional idx
	constructed_indicator[["idx"]] <- add_idx(
		constructed_series
	)

	## construct {${PKG}}-object
	state <- .chart_state()
	${METHOD}_object <- build_${METHOD}(
		init = state[["main"]],
#plotly#		traces = list(
#plotly#			list(
#plotly#				y = ~constructed_indicator[["${ALIAS}"]][-(1:attr(constructed_indicator, "lookback", TRUE))],
#plotly#				legendgroup = "MovingAverage",
#plotly#				legendgrouptitle = list(
#plotly#					text = "Moving Averages"
#plotly#				)
#plotly#			)
#plotly#		),
#ggplot#		layers = list(
#ggplot#			list(
#ggplot#				y = "${ALIAS}"
#ggplot#			)
#ggplot#		),
		name = label("${ALIAS}"${CARGS}),
		decorators = list(),
		data = constructed_indicator
	)
	state[["main"]] <- ${METHOD}_object

	${METHOD}_object
}
