#' @export
#' @family Momentum Indicator
#'
#' @title Average Directional Movement Index
#' @templateVar .title Average Directional Movement Index
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun average_directional_movement_index
#' @templateVar .family Momentum Indicator
#' @templateVar .formula ~ high + low + close
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
	map_dfr(
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
	average_directional_movement_index.default(
		x = x,
		cols = cols,
		n = n,
		...
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
	lower_bound = 25,
	middle_bound = 50,
	upper_bound = 75,
	## splice:optional-plotly:end
	title,
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
	name <- sprintf(
		"ADX(%d)",
		n
	)

	decorators <- list(
		function(p) add_limit(p, y_range = c(0, 100))
	)

	traces <- list(
		plotly_line(lower_bound, nrow(constructed_indicator)),
		plotly_line(middle_bound, nrow(constructed_indicator)),
		plotly_line(upper_bound, nrow(constructed_indicator)),
		list(y = ~ADX)
	)
	## splice:plotly-assembly:end

	plotly_object <- build_plotly(
		init = plotly_init(),
		traces = traces,
		decorators = decorators,
		name = name,
		data = constructed_indicator,
		title = if (missing(title)) {
			"Average Directional Movement Index"
		} else {
			title
		}
	)

	.plotting_environment$sub <- c(
		.plotting_environment$sub,
		list(plotly_object)
	)

	plotly_object
}
