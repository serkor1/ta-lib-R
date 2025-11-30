#' @title Merge Indicators
#'
#' @description
#' Placeholder
#'
#' @param x x
#' @param y y
#' @param ... ...
#'
#' @returns
#' A <plotly>-object
#'
#' @export
merge.plotly <- function(x, y, ...) {
	## assert both input
	## just in case
	assert_plotly(x)
	assert_plotly(y)

	## extract objects
	x_build <- plotly::plotly_build(x)
	y_build <- plotly::plotly_build(y)

	## initialize empty plotly object
	## with stuff
	chart_stuff <- list(
		function(p) layout_background(p),
		function(p) layout_font(p),
		function(p) layout_legend(p),
		function(p) layout_settings(p)
	)
	z_build <- Reduce(
		f = function(p, f) f(p),
		x = chart_stuff,
		init = plotly::plot_ly()
	)

	z_build$x$data <- c(x_build$x$data, y_build$x$data)

	z_build
}
