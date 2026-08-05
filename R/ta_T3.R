#' @export
#' @family Overlap Studies
#'
#' @title Triple Exponential Moving Average (T3)
#' @templateVar .title Triple Exponential Moving Average (T3)
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun t3_exponential_moving_average
#' @templateVar .family Overlap Studies
#' @templateVar .formula ~close
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @details
#' When passed without 'x', [t3_exponential_moving_average] functions as an 'Moving Average'-specification which is used in, for example, [stochastic] when constructing the smoothing lines.
#'
#' When called without 'x' it will return a named list which is used for the
#' indicators that supports various Moving Average specifications.
#'
#' @template description
#' @param volumeFactor ([double]). Volume Factor. Defaults to `0.7`.
#' @template returns
t3_exponential_moving_average <- function(
	x,
	timePeriod = 5,
	volumeFactor = 0.7,
	cols,
	na.bridge = FALSE,
	...
) {
	## if 'x' is missing t3_exponential_moving_average functions
	## as a Moving Average Specification
	if (missing(x)) {
		## construct Moving Average specification
		## from call
		x <- structure(
			list(
				timePeriod = if (missing(timePeriod)) {
					5L
				} else {
					as.integer(timePeriod)
				},
				volumeFactor = if (missing(volumeFactor)) {
					0.7
				} else {
					as.double(volumeFactor)
				},
				maType = 8L
			),
			class = "maType"
		)

		return(x)
	}

	UseMethod("t3_exponential_moving_average")
}

#' @export
#' @usage NULL
#' @rdname t3_exponential_moving_average
#'
#' @aliases t3_exponential_moving_average
T3 <- t3_exponential_moving_average

#' @export
#' @usage NULL
#' @rdname t3_exponential_moving_average
#'
#' @aliases t3_exponential_moving_average
t3ExponentialMovingAverage <- t3_exponential_moving_average

#' @usage NULL
#' @aliases t3_exponential_moving_average
#'
#' @export
t3_exponential_moving_average.default <- function(
	x,
	timePeriod = 5,
	volumeFactor = 0.7,
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
		C_impl_ta_T3,
		constructed_series[[1]],
		as.integer(timePeriod),
		as.double(volumeFactor),
		as.logical(na.bridge)
	)

	## readd rownames
	set_index(x, x_names)

	## return indicator
	x
}

#' @usage NULL
#' @aliases t3_exponential_moving_average
#'
#' @export
t3_exponential_moving_average.data.frame <- function(
	x,
	timePeriod = 5,
	volumeFactor = 0.7,
	cols,
	na.bridge = FALSE,
	...
) {
	as.data.frame(
		t3_exponential_moving_average.default(
			x = x,
			timePeriod = timePeriod,
			volumeFactor = volumeFactor,
			cols = cols,
			na.bridge = na.bridge,
			...
		)
	)
}

#' @usage NULL
#' @aliases t3_exponential_moving_average
#'
#' @export
t3_exponential_moving_average.matrix <- function(
	x,
	timePeriod = 5,
	volumeFactor = 0.7,
	cols,
	na.bridge = FALSE,
	...
) {
	as.matrix(
		t3_exponential_moving_average.default(
			x = x,
			timePeriod = timePeriod,
			volumeFactor = volumeFactor,
			cols = cols,
			na.bridge = na.bridge,
			...
		)
	)
}

#' @usage NULL
#' @aliases t3_exponential_moving_average
#'
#' @export
t3_exponential_moving_average.xts <- function(
	x,
	timePeriod = 5,
	volumeFactor = 0.7,
	cols,
	na.bridge = FALSE,
	...
) {
	assert_xts()

	as.xts(
		t3_exponential_moving_average.default(
			x = x,
			timePeriod = timePeriod,
			volumeFactor = volumeFactor,
			cols = cols,
			na.bridge = na.bridge,
			...
		)
	)
}


#' @usage NULL
#' @aliases t3_exponential_moving_average
#'
#' @export
t3_exponential_moving_average.numeric <- function(
	x,
	timePeriod = 5,
	volumeFactor = 0.7,
	cols,
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

	if (...length()) {
		warning("'...' is passed but is unused for vectors.")
	}

	## pass to 'C' directly
	## with the input vector
	x <- .Call(
		C_impl_ta_T3,
		as.double(x),
		as.integer(timePeriod),
		as.double(volumeFactor),
		as.logical(na.bridge)
	)

	if (dim(x)[2] == 1L) {
		dim(x) <- NULL
	}
	class(x) <- NULL

	x
}

#' @usage NULL
T3_lookback <- t3ExponentialMovingAverage_lookback <- t3_exponential_moving_average_lookback <- function(
	x,
	timePeriod = 5,
	volumeFactor = 0.7,
	cols,
	na.bridge = FALSE,
	...
) {
	.Call(
		C_impl_ta_T3_lookback,
		as.integer(timePeriod),
		as.double(volumeFactor)
	)
}

#' @usage NULL
#' @aliases t3_exponential_moving_average
#'
#' @export
t3_exponential_moving_average.plotly <- function(
	x,
	timePeriod = 5,
	volumeFactor = 0.7,
	cols,
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
	constructed_indicator <- t3_exponential_moving_average(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		timePeriod = timePeriod,
		volumeFactor = volumeFactor,
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
				y = ~ constructed_indicator[["T3"]][
					-(1:attr(constructed_indicator, "lookback", TRUE))
				],
				legendgroup = "MovingAverage",
				legendgrouptitle = list(
					text = "Moving Averages"
				)
			)
		),
		name = label("T3", timePeriod, volumeFactor),
		decorators = list(),
		data = constructed_indicator
	)
	state[["main"]] <- plotly_object

	plotly_object
}

#' @usage NULL
#' @aliases t3_exponential_moving_average
#'
#' @export
t3_exponential_moving_average.ggplot <- function(
	x,
	timePeriod = 5,
	volumeFactor = 0.7,
	cols,
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
	constructed_indicator <- t3_exponential_moving_average(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		timePeriod = timePeriod,
		volumeFactor = volumeFactor,
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
				y = "T3"
			)
		),
		name = label("T3", timePeriod, volumeFactor),
		decorators = list(),
		data = constructed_indicator
	)
	state[["main"]] <- ggplot_object

	ggplot_object
}
