#' @export
#' @family Momentum Indicator
#'
#' @title Average Directional Movement Index
#' @templateVar .title Average Directional Movement Index
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun average_directional_movement_index
#' @templateVar .family Momentum Indicator
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
#' @template returns
average_directional_movement_index <- function(
	x,
	cols,
	n = 10,
	...
) {
	UseMethod("average_directional_movement_index")
}

#' @export
#' @usage NULL
#' @rdname average_directional_movement_index
#'
#' @aliases average_directional_movement_index
ADX <- average_directional_movement_index

#' @usage NULL
#' @aliases average_directional_movement_index
#'
#' @export
average_directional_movement_index.default <- function(
	x,
	cols,
	n = 10,
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
		default = ~ high + low + close,
		data = x,
		...
	)

	## extract rownames
	## for later attachment
	x_names <- rownames(constructed_series)

	## calculate indicator and
	## return as data.frame
	x <- .Call(
		"impl_ta_ADX",
		## splice:call:start
		constructed_series[[1]],
		constructed_series[[2]],
		constructed_series[[3]],
		as.integer(n)
		## splice:call:end
	)

	## readd rownames
	set_rownames(x, x_names)

	## return indicator
	x
}

#' @usage NULL
#' @aliases average_directional_movement_index
#'
#' @export
average_directional_movement_index.data.frame <- function(
	x,
	cols,
	n = 10,
	...
) {
	as.data.frame(
		average_directional_movement_index.default(
			x = x,
			cols = cols,
			n = n,
			...
		)
	)
}

#' @usage NULL
#' @aliases average_directional_movement_index
#'
#' @export
average_directional_movement_index.matrix <- function(
	x,
	cols,
	n = 10,
	...
) {
	as.matrix(
		average_directional_movement_index.default(
			x = x,
			cols = cols,
			n = n,
			...
		)
	)
}

#' @usage NULL
#' @aliases average_directional_movement_index
#'
#' @export
average_directional_movement_index.plotly <- function(
	x,
	cols,
	n = 10,
	## splice:optional-plotly:start
	## splice:optional-plotly:end
	...
) {
	## check that input value
	## 'x' is <plotly>-object
	assert_plotly(x)

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
		default = ~ high + low + close,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- average_directional_movement_index(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		n = n
	)

	## add conditional idx
	constructed_indicator[["idx"]] <- add_idx(
		constructed_series
	)

	## construct {plotly}-object
	## splice:plotly-assembly:start
	plotly_object <- subchart(
		data = constructed_indicator,
		y = ~ADX,
		type = "scatter",
		mode = "lines",
		showlegend = FALSE
	)

	if (main_chart_exists()) {
		plotly_object <- add_title(
			x = plotly_object,
			text = "Average Directional Movement"
		)
	}

	.plotting_environment$sub <- c(
		.plotting_environment$sub,
		list(plotly_object)
	)
	## splice:plotly-assembly:end

	plotly_object
}
