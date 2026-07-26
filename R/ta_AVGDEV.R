#' @export
#' @family Price Transform
#'
#' @title Average Deviation
#' @templateVar .title Average Deviation
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun AVGDEV
#' @templateVar .family Price Transform
#' @templateVar .formula ~close
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
#' @template returns
AVGDEV <- function(
	x,
	cols,
	timePeriod = 14,
	na.bridge = FALSE,
	...
) {
	UseMethod("AVGDEV")
}

#' @export
#' @usage NULL
#' @rdname AVGDEV
#'
#' @aliases AVGDEV
AVGDEV <- AVGDEV

#' @usage NULL
#' @aliases AVGDEV
#'
#' @export
AVGDEV.default <- function(
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
		C_impl_ta_AVGDEV,
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
#' @aliases AVGDEV
#'
#' @export
AVGDEV.data.frame <- function(
	x,
	cols,
	timePeriod = 14,
	na.bridge = FALSE,
	...
) {
	map_dfr(
		AVGDEV.default(
			x = x,
			cols = cols,
			timePeriod = timePeriod,
			na.bridge = na.bridge,
			...
		)
	)
}

#' @usage NULL
#' @aliases AVGDEV
#'
#' @export
AVGDEV.matrix <- function(
	x,
	cols,
	timePeriod = 14,
	na.bridge = FALSE,
	...
) {
	AVGDEV.default(
		x = x,
		cols = cols,
		timePeriod = timePeriod,
		na.bridge = na.bridge,
		...
	)
}

#' @usage NULL
AVGDEV_lookback <- function(
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
#' @aliases AVGDEV
#'
#' @export
AVGDEV.numeric <- function(
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
