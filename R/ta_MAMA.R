#' @export
#' @family Overlap Study
#'
#' @title MESA Adaptive Moving Average
#' @templateVar .title MESA Adaptive Moving Average
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun mesa_adaptive_moving_average
#'
#' @returns
#' A [data.frame]- or [matrix]-object:
#'
#' \describe{
#'  \item{MAMA <[double]>}{Values}
#' }
#'
#' @template description
mesa_adaptive_moving_average <- function(
	x,
	cols,
	n = 10,
	...
) {
	## if 'x' is missing mesa_adaptive_moving_average functions
	## as a Moving Average Specification
	if (missing(x)) {
		## construct Moving Average specification
		## from call
		x <- structure(
			{
				list(
					n = if (missing(n)) 10L else as.integer(n),
					maType = 7L
				)
			}
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
		7L
	)

	## readd rownames
	rownames(x) <- x_names

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
	n = 10,
	...
) {
	as.data.frame(
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
	n = 10,
	...
) {
	## pass directly to
	## mesa_adaptive_moving_average.default to avoid
	## shenanigans with NextMethod()
	as.matrix(
		mesa_adaptive_moving_average.default(
			x = x,
			cols = cols,
			n = n,
			...
		)
	)
}

#' @usage NULL
#' @aliases mesa_adaptive_moving_average
#'
#' @export
mesa_adaptive_moving_average.numeric <- function(
	x,
	cols,
	n = 10,
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
		7L
	)

	## 'C' returns a named matrix
	## return the first column
	as.double(x)
}

#' @usage NULL
#' @aliases mesa_adaptive_moving_average
#'
#' @export
mesa_adaptive_moving_average.plotly <- function(
	x,
	cols,
	n = 10,
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
	constructed_indicator <- mesa_adaptive_moving_average(
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
	plotly_object <- .plotting_environment[["main"]] <- plotly::add_trace(
		.plotting_environment[["main"]],
		data = constructed_indicator,
		x = ~idx,
		y = constructed_indicator[["MAMA"]],
		type = "scatter",
		mode = "lines",
		name = sprintf("MAMA(%d)", n),
		inherit = FALSE
	)

	plotly_object
}
