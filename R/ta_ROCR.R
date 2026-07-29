#' @export
#' @family Momentum Indicators
#'
#' @title Rate of change ratio: (price/prevPrice)
#' @templateVar .title Rate of change ratio: (price/prevPrice)
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun ratio_of_change
#' @templateVar .family Momentum Indicators
#' @templateVar .formula ~close
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
#'
#' @template returns
ratio_of_change <- function(
	x,
	cols,
	timePeriod = 10,
	na.bridge = FALSE,
	...
) {
	UseMethod("ratio_of_change")
}

#' @export
#' @usage NULL
#' @rdname ratio_of_change
#'
#' @aliases ratio_of_change
ROCR <- ratio_of_change

#' @usage NULL
#' @aliases ratio_of_change
#'
#' @export
ratio_of_change.default <- function(
	x,
	cols,
	timePeriod = 10,
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
		C_impl_ta_ROCR,
		constructed_series[[1]],
		as.integer(timePeriod),
		as.logical(na.bridge)
	)

	## readd rownames
	set_rownames(x, x_names)

	## return indicator
	x
}

#' @usage NULL
#' @aliases ratio_of_change
#'
#' @export
ratio_of_change.data.frame <- function(
	x,
	cols,
	timePeriod = 10,
	na.bridge = FALSE,
	...
) {
	map_dfr(
		ratio_of_change.default(
			x = x,
			cols = cols,
			timePeriod = timePeriod,
			na.bridge = na.bridge,
			...
		)
	)
}

#' @usage NULL
#' @aliases ratio_of_change
#'
#' @export
ratio_of_change.matrix <- function(
	x,
	cols,
	timePeriod = 10,
	na.bridge = FALSE,
	...
) {
	ratio_of_change.default(
		x = x,
		cols = cols,
		timePeriod = timePeriod,
		na.bridge = na.bridge,
		...
	)
}

#' @usage NULL
ROCR_lookback <- ratio_of_change_lookback <- function(
	x,
	cols,
	timePeriod = 10,
	na.bridge = FALSE,
	...
) {
	.Call(
		C_impl_ta_ROCR_lookback,
		as.integer(timePeriod)
	)
}

#' @usage NULL
#' @aliases ratio_of_change
#'
#' @export
ratio_of_change.numeric <- function(
	x,
	cols,
	timePeriod = 10,
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
		C_impl_ta_ROCR,
		as.double(x),
		as.integer(timePeriod),
		as.logical(na.bridge)
	)

	if (dim(x)[2] == 1L) {
		dim(x) <- NULL
	}

	x
}

#' @usage NULL
#' @aliases ratio_of_change
#'
#' @export
ratio_of_change.plotly <- function(
	x,
	cols,
	timePeriod = 10,
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
	constructed_indicator <- ratio_of_change(
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
	name <- "ROCR"
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
				"Rate of change ratio: (price/prevPrice)"
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
#' @aliases ratio_of_change
#'
#' @export
ratio_of_change.ggplot <- function(
	x,
	cols,
	timePeriod = 10,
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
	constructed_indicator <- ratio_of_change(
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
	layers <- lapply(
		setdiff(colnames(constructed_indicator), "idx"),
		function(col) list(y = col)
	)
	name <- "ROCR"
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
				"Rate of change ratio: (price/prevPrice)"
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
