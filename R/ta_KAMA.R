#' @export
#' @family Overlap Study
#'
#' @title Kaufman Adaptive Moving Average
#' @templateVar .title Kaufman Adaptive Moving Average
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun kaufman_adaptive_moving_average
#'
#' @returns
#' A [data.frame]- or [matrix]-object:
#'
#' \describe{
#'  \item{KAMA <[double]>}{Values}
#' }
#'
#' @template description
kaufman_adaptive_moving_average <- function(
	x,
	cols,
	n = 10,
	...
) {
	## if 'x' is missing kaufman_adaptive_moving_average functions
	## as a Moving Average Specification
	if (missing(x)) {
		## construct Moving Average specification
		## from call
		x <- structure(
			{
				list(
					n = if (missing(n)) 10L else as.integer(n),
					maType = as.integer(6L)
				)
			}
		)

		return(x)
	}
	UseMethod("kaufman_adaptive_moving_average")
}

#' @export
#' @usage NULL
#' @rdname kaufman_adaptive_moving_average
#'
#' @aliases kaufman_adaptive_moving_average
KAMA <- kaufman_adaptive_moving_average

#' @usage NULL
#' @aliases kaufman_adaptive_moving_average
#'
#' @export
kaufman_adaptive_moving_average.default <- function(
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
		6L
	)

	## readd rownames
	rownames(x) <- x_names

	## return indicator
	x
}

#' @usage NULL
#' @aliases kaufman_adaptive_moving_average
#'
#' @export
kaufman_adaptive_moving_average.data.frame <- function(
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
#' @aliases kaufman_adaptive_moving_average
#'
#' @export
kaufman_adaptive_moving_average.matrix <- function(
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
#' @aliases kaufman_adaptive_moving_average
#'
#' @export
kaufman_adaptive_moving_average.plotly <- function(
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
	constructed_indicator <- kaufman_adaptive_moving_average(
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
		y = constructed_indicator[["KAMA"]],
		type = "scatter",
		mode = "lines",
		name = sprintf("KAMA(%d)", n),
		inherit = FALSE
	)

	plotly_object
}
