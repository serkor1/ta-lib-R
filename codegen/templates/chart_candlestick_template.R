#' @usage NULL
#' @aliases ${FUN}
#'
#' @export
${FUN}.${METHOD} <- function(
	x,
	cols,
	${ARGS}
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
		formula.default = ${FORMULA},
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- ${FUN}(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		${PARGS}
		na.bridge = na.bridge
	)

	## add conditional idx
	constructed_indicator[["idx"]] <- add_idx(
		constructed_series
	)

	## construct {${PKG}}-object
	state <- .chart_state()
	${METHOD}_object <- pattern_${SUFFIX}(
		p = state[["main"]],
		x = constructed_indicator,
		high = constructed_series[[2]],
		low = constructed_series[[3]],
		pattern_name = "${FUN}",
		agnostic = ${AGNOSTIC}
	)
	state[["main"]] <- ${METHOD}_object

	${METHOD}_object
}
