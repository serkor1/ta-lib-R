#' @export
#' @family Overlap Study
#'
#' @title Triple Exponential Moving Average (T3)
#' @templateVar .title Triple Exponential Moving Average (T3)
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun t3_exponential_moving_average
#'
#' @returns
#' A [data.frame]- or [matrix]-object:
#'
#' \describe{
#'  \item{T3 <[double]>}{Values}
#' }
#'
#' @template description
t3_exponential_moving_average <- function(
	x,
	cols,
	n = 10,
	...
) {
	## if 'x' is missing t3_exponential_moving_average functions
	## as a Moving Average Specification
	if (missing(x)) {
		## construct Moving Average specification
		## from call
		x <- structure(
			{
				list(
					n = if (missing(n)) 10L else as.integer(n),
					maType = as.integer(8L)
				)
			}
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

#' @usage NULL
#' @aliases t3_exponential_moving_average
#'
#' @export
t3_exponential_moving_average.default <- function(
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
		8L
	)

	## readd rownames
	rownames(x) <- x_names

	## return indicator
	x
}

#' @usage NULL
#' @aliases t3_exponential_moving_average
#'
#' @export
t3_exponential_moving_average.data.frame <- function(
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
#' @aliases t3_exponential_moving_average
#'
#' @export
t3_exponential_moving_average.matrix <- function(
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
#' @aliases t3_exponential_moving_average
#'
#' @export
t3_exponential_moving_average.plotly <- function(
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
	constructed_indicator <- t3_exponential_moving_average(
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
		y = constructed_indicator[["T3"]],
		type = "scatter",
		mode = "lines",
		name = sprintf("T3(%d)", n),
		inherit = FALSE
	)

	plotly_object
}
