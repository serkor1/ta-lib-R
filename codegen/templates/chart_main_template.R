#' @usage NULL
#' @aliases ${FUN}
#'
#' @export
${FUN}.${METHOD} <- function(
	x,
	cols,
	${ARGS}
	na.bridge = FALSE,
	## splice:optional-${METHOD}:start
	## splice:optional-${METHOD}:end
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
		na.bridge = TRUE
	)

	## add conditional idx
	constructed_indicator[["idx"]] <- add_idx(
		constructed_series
	)

	## construct {${PKG}}-object
	## splice:${METHOD}-assembly:start
#plotly#	traces <- lapply(
#plotly#		setdiff(colnames(constructed_indicator), "idx"),
#plotly#		function(col) {
#plotly#			list(
#plotly#				y = stats::as.formula(
#plotly#					paste0("~", col)
#plotly#				),
#plotly#				name = col
#plotly#			)
#plotly#		}
#plotly#	)
#ggplot#	layers <- lapply(
#ggplot#		setdiff(colnames(constructed_indicator), "idx"),
#ggplot#		function(col) list(y = col)
#ggplot#	)
	name <- "${ALIAS}"
	## splice:${METHOD}-assembly:end

	state <- .chart_state()
	${METHOD}_object <- build_${METHOD}(
		init = state[["main"]],
#plotly#		traces = traces,
#ggplot#		layers = layers,
		decorators = list(),
		name = get0(
			x = "name",
			ifnotfound = NULL
		),
		data = constructed_indicator
	)
	state[["main"]] <- ${METHOD}_object

	${METHOD}_object
}
