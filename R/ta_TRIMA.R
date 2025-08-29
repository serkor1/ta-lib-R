#' @title Triangular Moving Average (TRIMA)
#' @family Overlap Study
#' @export
TRIMA <- function(x, n = 10, ...) {
	UseMethod("TRIMA")
}

#' @rdname TRIMA
#' @usage NULL
#' @export
TRIMA.default <- function(x, n = 10, ...) {
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
		5L
	)
}


#' @rdname TRIMA
#' @usage NULL
#' @export
TRIMA.plotly <- function(x, n = 10, ...) {
	dots <- list(...)
	series <- dots$.series

	trima <- .Call(
		"impl_ta_MA",
		.univariate_series(series),
		as.integer(n),
		6L
	)

	df <- data.frame(
		idx = seq_along(trima),
		trima = as.numeric(trima)
	)

	.plotting_environment$main <- plotly::add_trace(
		x,
		data = df, # bind data here (creates/sets cur_data)
		x = ~idx,
		y = ~trima, # refer to columns, not objects in caller env
		type = "scatter",
		mode = "lines",
		name = sprintf("TRIMA(%d)", n),
		inherit = FALSE,
		xaxis = "x",
		yaxis = "y" # ensure it lands on the main panel
	)

	.plotting_environment$main
}
