#' @title Relative Strength Index
#' @family Momentum Indicator
#' @export
relative_strength_index <- function(x, n = 10, ...) {
	UseMethod(
		"relative_strength_index"
	)
}

#' @export
RSI <- relative_strength_index

#' @export
relative_strength_index.default <- function(x, n = 10, ...) {
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
		stop("`x` has to be a double vector")
	}
	assert(is.numeric(x))
	assert(n >= 2)

	## 1) pass `x` to C
	.Call(
		"impl_ta_RSI",
		x,
		as.integer(n)
	)
}

#' @export
relative_strength_index.plotly <- function(
	x,
	n = 10,
	lower = 20,
	upper = 80,
	...
) {
	dots <- list(...)
	series <- dots$.series[, 1L]
	rsi <- .Call("impl_ta_RSI", as.double(series), as.integer(n))
	df <- data.frame(idx = seq_along(rsi), value = rsi)

	rsi_plot <- plotly::plot_ly(
		df,
		x = ~idx,
		y = ~value,
		type = "scatter",
		mode = "lines",
		showlegend = FALSE
	)
	rsi_plot <- plotly::add_ribbons(
		rsi_plot,
		x = ~idx,
		ymin = rep(lower, nrow(df)),
		ymax = rep(upper, nrow(df)),
		line = list(width = 0),
		fillcolor = "rgba(160,160,160,0.20)"
	)

	.plotting_environment$sub <- c(
		.plotting_environment$sub,
		list(rsi_plot)
	)

	rsi_plot
}
