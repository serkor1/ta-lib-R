#' @export
#' @family Price Transform
#'
#' @title Average Deviation
#' @templateVar .title Average Deviation
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun average_deviation
#' @templateVar .family Price Transform
#' @templateVar .formula ~close
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
#'
#' @template returns
average_deviation <- function(
	x,
	cols,
	timePeriod = 14,
	na.bridge = FALSE,
	...
) {
	UseMethod("average_deviation")
}

#' @export
#' @usage NULL
#' @rdname average_deviation
#'
#' @aliases average_deviation
AVGDEV <- average_deviation

#' @export
#' @usage NULL
#' @rdname average_deviation
#'
#' @aliases average_deviation
averageDeviation <- average_deviation

#' @usage NULL
#' @aliases average_deviation
#'
#' @export
average_deviation.default <- function(
	x,
	cols,
	timePeriod = 14,
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
		formula = cols,
		formula.default = ~close,
		...
	)

	## extract rownames
	## for later attachment
	x_names <- index(constructed_series)

	## calculate indicator and
	## return as data.frame
	x <- .Call(
		C_impl_ta_AVGDEV,
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
#' @aliases average_deviation
#'
#' @export
average_deviation.data.frame <- function(
	x,
	cols,
	timePeriod = 14,
	na.bridge = FALSE,
	...
) {
	as.data.frame(
		average_deviation.default(
			x = x,
			cols = cols,
			timePeriod = timePeriod,
			na.bridge = na.bridge,
			...
		)
	)
}

#' @usage NULL
#' @aliases average_deviation
#'
#' @export
average_deviation.matrix <- function(
	x,
	cols,
	timePeriod = 14,
	na.bridge = FALSE,
	...
) {
	as.matrix(
		average_deviation.default(
			x = x,
			cols = cols,
			timePeriod = timePeriod,
			na.bridge = na.bridge,
			...
		)
	)
}

#' @usage NULL
#' @aliases average_deviation
#'
#' @export
average_deviation.xts <- function(
	x,
	cols,
	timePeriod = 14,
	na.bridge = FALSE,
	...
) {
	assert_xts()

	as.xts(
		average_deviation.default(
			x = x,
			cols = cols,
			timePeriod = timePeriod,
			na.bridge = na.bridge,
			...
		)
	)
}

#' @usage NULL
AVGDEV_lookback <- averageDeviation_lookback <- average_deviation_lookback <- function(
	x,
	cols,
	timePeriod = 14,
	na.bridge = FALSE,
	...
) {
	.Call(
		C_impl_ta_AVGDEV_lookback,
		as.integer(timePeriod)
	)
}

#' @usage NULL
#' @aliases average_deviation
#'
#' @export
average_deviation.numeric <- function(
	x,
	cols,
	timePeriod = 14,
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
		C_impl_ta_AVGDEV,
		as.double(x),
		as.integer(timePeriod),
		as.logical(na.bridge)
	)

	if (dim(x)[2] == 1L) {
		dim(x) <- NULL
	}

	x
}
