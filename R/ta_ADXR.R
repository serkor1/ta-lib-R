#' @export
#' @family Momentum Indicator
#'
#' @title Average Directional Movement Index Rating
#' @templateVar .title Average Directional Movement Index Rating
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun average_direcitonal_movement_rating
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
average_direcitonal_movement_rating <- function(
	x,
	cols,
	n = 10,
	...
) {
	UseMethod("average_direcitonal_movement_rating")
}

#' @export
#' @usage NULL
#' @rdname average_direcitonal_movement_rating
#'
#' @aliases average_direcitonal_movement_rating
ADXR <- average_direcitonal_movement_rating

#' @usage NULL
#' @aliases average_direcitonal_movement_rating
#'
#' @export
average_direcitonal_movement_rating.default <- function(
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

	## extract rownames
	## for later attachment
	x_names <- rownames(x)

	## construct series
	## from input
	constructed_series <- series(
		x = cols,
		default = ~ high + low + close,
		data = x,
		...
	)

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
	rownames(x) <- x_names

	## return indicator
	x
}

#' @usage NULL
#' @aliases average_direcitonal_movement_rating
#'
#' @export
average_direcitonal_movement_rating.data.frame <- function(
	x,
	cols,
	n = 10,
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases average_direcitonal_movement_rating
#'
#' @export
average_direcitonal_movement_rating.matrix <- function(
	x,
	cols,
	n = 10,
	...
) {
	as.matrix(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases average_direcitonal_movement_rating
#'
#' @export
average_direcitonal_movement_rating.plotly <- function(
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
	constructed_indicator <- average_direcitonal_movement_rating(
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

	if (main_chart_exists()) {
		plotly_object <- add_title(
			x = plotly_object,
			text = "Average Directional Movement Index"
		)
	}

	.plotting_environment$sub <- c(
		.plotting_environment$sub,
		list(plotly_object)
	)
	## splice:plotly-assembly:end

	plotly_object
}
