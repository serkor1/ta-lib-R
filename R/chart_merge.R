#' @title Merge Indicators
#'
#' @description
#' Placeholder
#'
#' @param x x
#' @param y y
#' @param ... ...
#'
#' @keywords internal
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

#' @rdname merge.plotly
#' @export
merge.ggplot <- function(x, y, ...) {
	assert_ggplot2()

	## combine layers from both plots
	## onto a single ggplot canvas
	z <- x
	for (layer in y$layers) {
		z <- z + layer
	}

	z + ggplot_chart_theme()
}

## ---- internal subchart merge ----

## Merge multiple subchart panels into one (plotly backend).
##
## Takes entries from..to in .chart_environment$sub,
## combines their traces onto the first panel, and
## reassigns colors so each indicator is visually distinct.
merge_subchart_plotly <- function(from, to) {
	## build the base panel
	base <- plotly::plotly_build(.chart_environment$sub[[from]])

	## merge traces and annotations from subsequent panels
	for (i in seq(from + 1L, to)) {
		other <- plotly::plotly_build(.chart_environment$sub[[i]])
		base$x$data <- c(base$x$data, other$x$data)

		## merge annotations (subchart titles, last-value labels)
		if (length(other$x$layout$annotations) > 0L) {
			base$x$layout$annotations <- c(
				base$x$layout$annotations,
				other$x$layout$annotations
			)
		}
	}

	## remove explicit y-range so plotly auto-scales
	## for the combined data
	base$x$layout$yaxis$range <- NULL
	base$x$layout$yaxis$autorange <- TRUE

	## reassign colors to legend-bearing traces
	## so merged indicators are visually distinct
	colorway <- .chart_variables$colorway
	color_i <- 0L
	for (j in seq_along(base$x$data)) {
		tr <- base$x$data[[j]]
		if (isTRUE(tr$showlegend)) {
			color_i <- color_i + 1L
			color <- colorway[((color_i - 1L) %% length(colorway)) + 1L]
			base$x$data[[j]]$line$color <- color
		}
	}

	## replace first panel with merged, drop the rest
	.chart_environment$sub[[from]] <- base
	length(.chart_environment$sub) <- from
}

## Merge multiple subchart panels into one (ggplot2 backend).
merge_subchart_ggplot <- function(from, to) {
	base <- .chart_environment$sub[[from]]

	## collect layers from subsequent panels
	for (i in seq(from + 1L, to)) {
		other <- .chart_environment$sub[[i]]
		for (layer in other$layers) {
			base <- base + layer
		}
	}

	## remove coord constraints so the merged
	## panel auto-scales for combined data
	suppressMessages(
		base <- base + ggplot2::coord_cartesian()
	)

	## rebuild color scale for all legend entries
	colorway <- .chart_variables$colorway
	legend_names <- character(0)
	for (layer in base$layers) {
		if (!is.null(layer$data) && ".legend" %in% names(layer$data)) {
			legend_names <- c(
				legend_names,
				unique(layer$data[[".legend"]])
			)
		}
	}
	legend_names <- unique(legend_names)

	if (length(legend_names) > 0L) {
		color_map <- setNames(
			colorway[seq_along(legend_names)],
			legend_names
		)

		## remove existing colour scale
		base$scales$scales <- Filter(
			function(s) !("colour" %in% s$aesthetics),
			base$scales$scales
		)
		base <- base +
			ggplot2::scale_colour_manual(
				name = NULL,
				values = color_map,
				breaks = legend_names
			)
	}

	## replace first panel with merged, drop the rest
	.chart_environment$sub[[from]] <- base
	length(.chart_environment$sub) <- from
}
