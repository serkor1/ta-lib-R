#' @export
#' @family Momentum Indicator
#'
#' @title Average Directional Movement Index Rating
#' @templateVar .title Average Directional Movement Index Rating
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun average_directional_movement_index_rating
#' @templateVar .family Momentum Indicator
#' @templateVar .formula ~ high + low + close
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
#' @template returns
average_directional_movement_index_rating <- function(
	x,
	cols,
	n = 10,
	...
) {
	UseMethod("average_directional_movement_index_rating")
}

#' @export
#' @usage NULL
#' @rdname average_directional_movement_index_rating
#'
#' @aliases average_directional_movement_index_rating
ADXR <- average_directional_movement_index_rating

#' @usage NULL
#' @aliases average_directional_movement_index_rating
#'
#' @export
average_directional_movement_index_rating.default <- function(
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
		"impl_ta_ADXR",
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
#' @aliases average_directional_movement_index_rating
#'
#' @export
average_directional_movement_index_rating.data.frame <- function(
	x,
	cols,
	n = 10,
	...
) {
	map_dfr(
		average_directional_movement_index_rating.default(
			x = x,
			cols = cols,
			n = n,
			...
		)
	)
}

#' @usage NULL
#' @aliases average_directional_movement_index_rating
#'
#' @export
average_directional_movement_index_rating.matrix <- function(
	x,
	cols,
	n = 10,
	...
) {
	average_directional_movement_index_rating.default(
		x = x,
		cols = cols,
		n = n,
		...
	)
}

#' @usage NULL
#' @aliases average_directional_movement_index_rating
#'
#' @export
average_directional_movement_index_rating.plotly <- function(
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
	constructed_indicator <- average_directional_movement_index_rating(
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
		y = ~ADXR,
		type = "scatter",
		mode = "lines",
		showlegend = FALSE
	)

	.plotting_environment$sub <- c(
		.plotting_environment$sub,
		list(plotly_object)
	)
	## splice:plotly-assembly:end

	plotly_object
}
