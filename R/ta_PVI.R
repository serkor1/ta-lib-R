#' @export
#' @family Volume Indicators
#'
#' @title Positive Volume Index
#' @templateVar .title Positive Volume Index
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun positive_volume_index
#' @templateVar .family Volume Indicators
#' @templateVar .formula ~close + volume
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
#'
#' @template returns
positive_volume_index <- function(
	x,
	cols,
	na.bridge = FALSE,
	...
) {
	UseMethod("positive_volume_index")
}

#' @export
#' @usage NULL
#' @rdname positive_volume_index
#'
#' @aliases positive_volume_index
PVI <- positive_volume_index

#' @export
#' @usage NULL
#' @rdname positive_volume_index
#'
#' @aliases positive_volume_index
positiveVolumeIndex <- positive_volume_index

#' @usage NULL
#' @aliases positive_volume_index
#'
#' @export
positive_volume_index.default <- function(
	x,
	cols,
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
		default_formula = ~ close + volume,
		data = x,
		...
	)

	## extract rownames
	## for later attachment
	x_names <- rownames(constructed_series)

	## calculate indicator and
	## return as data.frame
	x <- .Call(
		C_impl_ta_PVI,
		constructed_series[[1]],
		constructed_series[[2]],
		as.logical(na.bridge)
	)

	## readd rownames
	set_rownames(x, x_names)

	## return indicator
	x
}

#' @usage NULL
#' @aliases positive_volume_index
#'
#' @export
positive_volume_index.data.frame <- function(
	x,
	cols,
	na.bridge = FALSE,
	...
) {
	map_dfr(
		positive_volume_index.default(
			x = x,
			cols = cols,
			na.bridge = na.bridge,
			...
		)
	)
}

#' @usage NULL
#' @aliases positive_volume_index
#'
#' @export
positive_volume_index.matrix <- function(
	x,
	cols,
	na.bridge = FALSE,
	...
) {
	positive_volume_index.default(
		x = x,
		cols = cols,
		na.bridge = na.bridge,
		...
	)
}

#' @usage NULL
PVI_lookback <- positiveVolumeIndex_lookback <- positive_volume_index_lookback <- function(
	x,
	cols,
	na.bridge = FALSE,
	...
) {
	.Call(
		C_impl_ta_PVI_lookback
	)
}

#' @usage NULL
#' @aliases positive_volume_index
#'
#' @export
positive_volume_index.plotly <- function(
	x,
	cols,
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
		default_formula = ~ close + volume,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- positive_volume_index(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
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
	name <- "PVI"
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
				"Positive Volume Index"
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
#' @aliases positive_volume_index
#'
#' @export
positive_volume_index.ggplot <- function(
	x,
	cols,
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
		default_formula = ~ close + volume,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- positive_volume_index(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
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
	name <- "PVI"
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
				"Positive Volume Index"
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
