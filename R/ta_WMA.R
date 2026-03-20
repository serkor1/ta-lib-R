#' @export
#' @family Overlap Study
#'
#' @title Weighted Moving Average
#' @templateVar .title Weighted Moving Average
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun weighted_moving_average
#' @templateVar .family Overlap Study
#' @templateVar .formula ~close
#'
#' @details
#' When passed without 'x', [weighted_moving_average] functions as an 'Moving Average'-specification which is used in, for example, [stochastic] when constructing the smoothing lines.
#'
#' When called without 'x' it will return a named list which is used for the
#' indicators that supports various Moving Average specifications.
#'
#' @template description
#' @template returns
weighted_moving_average <- function(
	x,
	cols,
	n = 10,
	na.ignore = FALSE,
	...
) {
	## if 'x' is missing weighted_moving_average functions
	## as a Moving Average Specification
	if (missing(x)) {
		## construct Moving Average specification
		## from call
		x <- structure(
			{
				list(
					n = if (missing(n)) 10L else as.integer(n),
					maType = 2L
				)
			}
		)

		return(x)
	}
	UseMethod("weighted_moving_average")
}

#' @export
#' @usage NULL
#' @rdname weighted_moving_average
#'
#' @aliases weighted_moving_average
WMA <- weighted_moving_average

#' @usage NULL
#' @aliases weighted_moving_average
#'
#' @export
weighted_moving_average.default <- function(
	x,
	cols,
	n = 10,
	na.ignore = FALSE,
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
		default = ~close,
		data = x,
		...
	)

	## extract rownames
	## for later attachment
	x_names <- rownames(constructed_series)

	## calculate indicator and
	## return as data.frame
	x <- .Call(
		"impl_ta_MA",
		as.double(constructed_series[[1]]),
		as.integer(n),
		2L,
		as.logical(na.ignore)
	)

	## readd rownames
	set_rownames(x, x_names)

	## return indicator
	x
}

#' @usage NULL
#' @aliases weighted_moving_average
#'
#' @export
weighted_moving_average.data.frame <- function(
	x,
	cols,
	n = 10,
	na.ignore = FALSE,
	...
) {
	map_dfr(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases weighted_moving_average
#'
#' @export
weighted_moving_average.matrix <- function(
	x,
	cols,
	n = 10,
	na.ignore = FALSE,
	...
) {
	## pass directly to
	## weighted_moving_average.default to avoid
	## shenanigans with NextMethod()
	weighted_moving_average.default(
		x = x,
		cols = cols,
		n = n,
		na.ignore = na.ignore,
		...
	)
}

#' @usage NULL
#' @aliases weighted_moving_average
#'
#' @export
weighted_moving_average.numeric <- function(
	x,
	cols,
	n = 10,
	na.ignore = FALSE,
	...
) {
	## warn if 'cols' have been
	## passed just to make sure
	## the user knows its not possible
	## or relevant
	if (!missing(cols)) {
		warning("'cols' is passed but is unused for vectors.")
	}

	## pass to 'C' directly
	## with the input vector
	x <- .Call(
		"impl_ta_MA",
		as.double(x),
		as.integer(n),
		2L,
		as.logical(na.ignore)
	)

	## 'C' returns a named matrix
	## return the first column
	x <- as.double(x)

	x
}

#' @usage NULL
#' @aliases weighted_moving_average
#'
#' @export
weighted_moving_average.plotly <- function(
	x,
	cols,
	n = 10,
	na.ignore = FALSE,
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
		default = ~close,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- weighted_moving_average(
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
	plotly_object <- .chart_environment[["main"]] <- build_plotly(
		init = .chart_environment[["main"]],
		traces = list(
			list(
				y = ~ constructed_indicator[["WMA"]][
					-(1:attr(constructed_indicator, "lookback", TRUE))
				],
				legendgroup = "MovingAverage",
				legendgrouptitle = list(
					text = "Moving Averages"
				)
			)
		),
		name = sprintf("WMA(%d)", n),
		decorators = list()
	)

	plotly_object
}


#' @usage NULL
#' @aliases weighted_moving_average
#'
#' @export
weighted_moving_average.ggplot <- function(
	x,
	cols,
	n = 10,
	na.ignore = FALSE,
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
		default = ~close,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- weighted_moving_average(
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

	## construct {ggplot2}-object
	ggplot_object <- .chart_environment[["main"]] <- build_ggplot(
		init = .chart_environment[["main"]],
		layers = list(
			list(
				y = "WMA"
			)
		),
		name = sprintf("WMA(%d)", n),
		decorators = list(),
		data = constructed_indicator
	)

	ggplot_object
}
