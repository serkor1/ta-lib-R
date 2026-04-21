#' @export
#' @family Overlap Study
#'
#' @title MESA Adaptive Moving Average
#' @templateVar .title MESA Adaptive Moving Average
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun mesa_adaptive_moving_average
#' @templateVar .family Overlap Study
#' @templateVar .formula ~close
#'
## splice:documentation:start
#' @param n ([integer]). Present only for interface uniformity with the other Moving Average specifications (see e.g. [simple_moving_average]) so that every MA spec exposes a uniform `n` field to downstream consumers (e.g. [bollinger_bands], [stochastic], [extended_moving_average_convergence_divergence]). **`n` has no effect on the standalone calculation of [mesa_adaptive_moving_average]** - the actual smoothing is controlled entirely by `fast` and `slow`.
#' @param fast ([double]). Upper limit of the adaptive smoothing factor (alpha) used in the MESA algorithm. A [double] in `[0.01, 0.99]`. `0.5` by default.
#' @param slow ([double]). Lower limit of the adaptive smoothing factor (alpha) used in the MESA algorithm. A [double] in `[0.01, 0.99]`. `0.05` by default.
## splice:documentation:end
#'
#' @details
#' When passed without 'x', [mesa_adaptive_moving_average] functions as an 'Moving Average'-specification which is used in, for example, [stochastic] when constructing the smoothing lines.
#'
#' When called without 'x' it will return a named list which is used for the
#' indicators that supports various Moving Average specifications.
#'
#' @template description
#' @template returns
mesa_adaptive_moving_average <- function(
	x,
	cols,
	n = 30,
	fast = 0.5,
	slow = 0.05,
	na.bridge = FALSE,
	...
) {
	## if 'x' is missing mesa_adaptive_moving_average functions
	## as a Moving Average Specification
	if (missing(x)) {
		## construct Moving Average specification
		## from call
		x <- structure(
			list(
				n = if (missing(n)) 30L else as.integer(n),
				fast = if (missing(fast)) 0.5 else as.double(fast),
				slow = if (missing(slow)) 0.05 else as.double(slow),
				maType = 7L
			)
		)

		return(x)
	}
	UseMethod("mesa_adaptive_moving_average")
}

#' @export
#' @usage NULL
#' @rdname mesa_adaptive_moving_average
#'
#' @aliases mesa_adaptive_moving_average
MAMA <- mesa_adaptive_moving_average

#' @usage NULL
#' @aliases mesa_adaptive_moving_average
#'
#' @export
mesa_adaptive_moving_average.default <- function(
	x,
	cols,
	n = 30,
	fast = 0.5,
	slow = 0.05,
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
		C_impl_ta_MAMA,
		as.double(constructed_series[[1]]),
		as.double(fast),
		as.double(slow),
		as.logical(na.bridge)
	)

	## readd rownames
	set_rownames(x, x_names)

	## return indicator
	x
}

#' @usage NULL
#' @aliases mesa_adaptive_moving_average
#'
#' @export
mesa_adaptive_moving_average.data.frame <- function(
	x,
	cols,
	n = 30,
	fast = 0.5,
	slow = 0.05,
	na.bridge = FALSE,
	...
) {
	map_dfr(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases mesa_adaptive_moving_average
#'
#' @export
mesa_adaptive_moving_average.matrix <- function(
	x,
	cols,
	n = 30,
	fast = 0.5,
	slow = 0.05,
	na.bridge = FALSE,
	...
) {
	## pass directly to
	## mesa_adaptive_moving_average.default to avoid
	## shenanigans with NextMethod()
	mesa_adaptive_moving_average.default(
		x = x,
		cols = cols,
		n = n,
		fast = fast,
		slow = slow,
		na.bridge = na.bridge,
		...
	)
}

#' @usage NULL
#' @aliases mesa_adaptive_moving_average
#'
#' @export
mesa_adaptive_moving_average.numeric <- function(
	x,
	cols,
	n = 30,
	fast = 0.5,
	slow = 0.05,
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
		C_impl_ta_MAMA,
		as.double(x),
		as.double(fast),
		as.double(slow),
		as.logical(na.bridge)
	)

	## check if it has 'dims'
	## and convert to double if
	## not to honor the 'type-safety'-esque
	## approach
	##
	## NOTE: this adds a few ns overhead but
	##       its a robust alternative to code it
	##       manually. Any suggestions are welcome
	if (is.null(dim(x))) {
		x <- as.double(x)
	}

	x
}

#' @usage NULL
#' @aliases mesa_adaptive_moving_average
#'
#' @export
mesa_adaptive_moving_average.plotly <- function(
	x,
	cols,
	n = 30,
	fast = 0.5,
	slow = 0.05,
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
		default = ~close,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- mesa_adaptive_moving_average(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		n = n,
		fast = fast,
		slow = slow
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
				y = ~ constructed_indicator[["MAMA"]][
					-(1:attr(constructed_indicator, "lookback", TRUE))
				],
				legendgroup = "MovingAverage",
				legendgrouptitle = list(
					text = "Moving Averages"
				)
			)
		),
		name = label("MAMA", fast, slow),
		decorators = list()
	)
	state[["main"]] <- plotly_object

	plotly_object
}


#' @usage NULL
#' @aliases mesa_adaptive_moving_average
#'
#' @export
mesa_adaptive_moving_average.ggplot <- function(
	x,
	cols,
	n = 30,
	fast = 0.5,
	slow = 0.05,
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
		default = ~close,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- mesa_adaptive_moving_average(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		n = n,
		fast = fast,
		slow = slow
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
				y = "MAMA"
			)
		),
		name = label("MAMA", fast, slow),
		decorators = list(),
		data = constructed_indicator
	)
	state[["main"]] <- ggplot_object

	ggplot_object
}
