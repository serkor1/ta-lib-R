#' @title Double Exponential Moving Average (DEMA)
#'
#' @family Overlap Study
#'
#' @templateVar .FUN DEMA
#' @template univariate_example
#'
#' @export
DEMA <- function(x, n = 10, ...) {
	UseMethod("DEMA")
}

#' @rdname DEMA
#' @usage NULL
#' @export
DEMA.default <- function(x, n = 10, ...) {
	## default behaviour is to
	## check if its a numeric vector
	##
	## No coercing here as it might
	## lead to overflow

	## 0) validate input
	##    and stop the script
	##    if conditions are not
	##    met
	if (!is.null(dim(x))) {
		stop("`x` must be a numeric vector")
	}
	assert(is.numeric(x))
	assert(n >= 2)

	## 1) pass `x` to C
	.Call(
		"impl_ta_MA",
		x,
		as.integer(n),
		3L
	)
}

#' @rdname DEMA
#' @usage NULL
#' @export
DEMA.plotly <- function(x, n = 10, ...) {
	dots <- list(...)
	series <- dots$.series

	dema <- .Call(
		"impl_ta_MA",
		.univariate_series(series),
		as.integer(n),
		3L
	)

	df <- data.frame(
		idx = seq_along(dema),
		dema = as.numeric(dema)
	)

	.plotting_environment$main <- plotly::add_trace(
		x,
		data = df, # bind data here (creates/sets cur_data)
		x = ~idx,
		y = ~dema, # refer to columns, not objects in caller env
		type = "scatter",
		mode = "lines",
		name = sprintf("DEMA(%d)", n),
		inherit = FALSE,
		xaxis = "x",
		yaxis = "y" # ensure it lands on the main panel
	)

	.plotting_environment$main
}
