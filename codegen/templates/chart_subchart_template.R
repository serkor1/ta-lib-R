#' @usage NULL
#' @aliases ${FUN}
#'
#' @export
${FUN}.${METHOD} <- function(
	x,
	cols,
	${ARGS}
	na.bridge = FALSE,
#plotly#	## splice:optional-${METHOD}:start
#plotly#	## splice:optional-${METHOD}:end
#plotly#	title,
#ggplot#	title,
#ggplot#	## splice:optional-${METHOD}:start
#ggplot#	## splice:optional-${METHOD}:end
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

	## the constructed indicator
#plotly#	## always returns excpected
#ggplot#	## always returns expected
	## columns which can be passed
#plotly#	## down to add_last_values()
#ggplot#	## down to add_last_value_gg()
	values_to_extract <- colnames(constructed_indicator)

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

	${METHOD}_object <- add_last_value_${SUFFIX}(
		build_${METHOD}(
			init = ${METHOD}_init(),
#plotly#			traces = traces,
#ggplot#			layers = layers,
			decorators = get0(
				x = "decorators",
				ifnotfound = list()
			),
			name = get0(
				x = "name",
				ifnotfound = NULL
			),
			data = constructed_indicator,
			title = if (missing(title)) {"${TITLE}"} else {title}
		),
		data = constructed_indicator[,values_to_extract, drop = FALSE],
#plotly#		values_to_extract = values_to_extract,
#plotly#		name = get0(x = "name", ifnotfound = NULL)
#ggplot#		values_to_extract = values_to_extract,
#ggplot#		name = get0(x = "name", ifnotfound = NULL)
	)

	state <- .chart_state()
	state$sub <- c(state$sub, list(${METHOD}_object))

	${METHOD}_object
}
