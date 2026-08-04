#' @export
#' @family Overlap Studies
#'
#' @title Simple Moving Average
#' @templateVar .title Simple Moving Average
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun simple_moving_average
#' @templateVar .family Overlap Studies
#' @templateVar .formula ~close
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @details
#' When passed without 'x', [simple_moving_average] functions as an 'Moving Average'-specification which is used in, for example, [stochastic] when constructing the smoothing lines.
#'
#' When called without 'x' it will return a named list which is used for the
#' indicators that supports various Moving Average specifications.
#'
#' @template description
#'
#' @template returns
simple_moving_average <- function(
	x,
	cols,
	timePeriod = 30,
	na.bridge = FALSE,
	...
) {
	## if 'x' is missing simple_moving_average functions
	## as a Moving Average Specification
	if (missing(x)) {
		## construct Moving Average specification
		## from call
		x <- structure(
			list(
				timePeriod = if (missing(timePeriod)) {
					30L
				} else {
					as.integer(timePeriod)
				},
				maType = 0L
			),
			class = "maType"
		)

		return(x)
	}

	UseMethod("simple_moving_average")
}

#' @export
#' @usage NULL
#' @rdname simple_moving_average
#'
#' @aliases simple_moving_average
SMA <- simple_moving_average

#' @export
#' @usage NULL
#' @rdname simple_moving_average
#'
#' @aliases simple_moving_average
simpleMovingAverage <- simple_moving_average

#' @usage NULL
#' @aliases simple_moving_average
#'
#' @export
simple_moving_average.default <- function(
	x,
	cols,
	timePeriod = 30,
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
		x = x,
		formula.default = ~close,
		formula = cols,
		...
	)

	## extract rownames
	## for later attachment
	x_names <- index(constructed_series)

	## calculate indicator and
	## return as data.frame
	x <- .Call(
		C_impl_ta_SMA,
		constructed_series[[1]],
		as.integer(timePeriod),
		as.logical(na.bridge)
	)

	## readd rownames
	set_index(x, x_names)

	## return indicator
	x
}

#' @usage NULL
#' @aliases simple_moving_average
#'
#' @export
simple_moving_average.data.frame <- function(
	x,
	cols,
	timePeriod = 30,
	na.bridge = FALSE,
	...
) {
	as.data.frame(
		simple_moving_average.default(
			x = x,
			cols = cols,
			timePeriod = timePeriod,
			na.bridge = na.bridge,
			...
		)
	)
}

#' @usage NULL
#' @aliases simple_moving_average
#'
#' @export
simple_moving_average.matrix <- function(
	x,
	cols,
	timePeriod = 30,
	na.bridge = FALSE,
	...
) {
	as.matrix(
		simple_moving_average.default(
			x = x,
			cols = cols,
			timePeriod = timePeriod,
			na.bridge = na.bridge,
			...
		)
	)
}

#' @usage NULL
#' @aliases simple_moving_average
#'
#' @export
simple_moving_average.xts <- function(
	x,
	cols,
	timePeriod = 30,
	na.bridge = FALSE,
	...
) {
	assert_xts()

	as.xts(
		simple_moving_average.default(
			x = x,
			cols = cols,
			timePeriod = timePeriod,
			na.bridge = na.bridge,
			...
		)
	)
}


#' @usage NULL
#' @aliases simple_moving_average
#'
#' @export
simple_moving_average.numeric <- function(
	x,
	cols,
	timePeriod = 30,
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

	## pass to 'C' directly
	## with the input vector
	x <- .Call(
		C_impl_ta_SMA,
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
SMA_lookback <- simpleMovingAverage_lookback <- simple_moving_average_lookback <- function(
	x,
	cols,
	timePeriod = 30,
	na.bridge = FALSE,
	...
) {
	.Call(
		C_impl_ta_SMA_lookback,
		as.integer(timePeriod)
	)
}


#' @usage NULL
#' @aliases simple_moving_average
#'
#' @export
simple_moving_average.plotly <- function(
	x,
	cols,
	timePeriod = 30,
	na.bridge = FALSE,
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
		formula.default = ~close,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- simple_moving_average(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		timePeriod = timePeriod,
		na.bridge = TRUE
	)

	## add conditional idx
	constructed_indicator[["idx"]] <- add_idx(
		constructed_series
	)

	## construct {plotly}-object
	state <- .chart_state()
	plotly_object <- build_plotly(
		init = state[["main"]],
		traces = list(
			list(
				y = ~ constructed_indicator[["SMA"]][
					-(1:attr(constructed_indicator, "lookback", TRUE))
				],
				legendgroup = "MovingAverage",
				legendgrouptitle = list(
					text = "Moving Averages"
				)
			)
		),
		name = label("SMA", timePeriod),
		decorators = list(),
		data = constructed_indicator
	)
	state[["main"]] <- plotly_object

	plotly_object
}

#' @usage NULL
#' @aliases simple_moving_average
#'
#' @export
simple_moving_average.ggplot <- function(
	x,
	cols,
	timePeriod = 30,
	na.bridge = FALSE,
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
		formula.default = ~close,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- simple_moving_average(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		timePeriod = timePeriod,
		na.bridge = TRUE
	)

	## add conditional idx
	constructed_indicator[["idx"]] <- add_idx(
		constructed_series
	)

	## construct {ggplot2}-object
	state <- .chart_state()
	ggplot_object <- build_ggplot(
		init = state[["main"]],
		layers = list(
			list(
				y = "SMA"
			)
		),
		name = label("SMA", timePeriod),
		decorators = list(),
		data = constructed_indicator
	)
	state[["main"]] <- ggplot_object

	ggplot_object
}
