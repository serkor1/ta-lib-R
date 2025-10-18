.chart_layout <- function(
	x,
	title_text,
	idx = NULL,
	...
) {
	## extract chart theme
	## from R/chart_options.R
	chart_theme <- .chart_theme()

	## hardcoded layout elements
	## and added flexibility in ellipsis
	plotly_object <- plotly::layout(
		p = x,
		paper_bgcolor = chart_theme$paper_bgcolor,
		plot_bgcolor = chart_theme$plot_bgcolor,
		font = list(
			size = 14 *
				getOption(
					"talib.chart.scale",
					default = 1
				),
			color = chart_theme$font_color
		),
		yaxis = list(
			title = '',
			gridcolor = chart_theme$grid_color
		),
		xaxis = list(
			title = '',
			gridcolor = chart_theme$grid_color,
			rangeslider = list(
				visible = getOption(
					"talib.chart.slider",
					default = FALSE
				),
				thickness = getOption(
					"talib.chart.slider.size",
					default = 0.05
				)
			),
			tickvals = seq_along(idx),
			tickmode = "auto",
			ticktext = idx
		),

		## legend start
		showlegend = getOption(
			"talib.chart.legend",
			default = TRUE
		),
		legend = list(
			orientation = 'h',
			x = 0,
			y = 100,
			yref = "container",
			title = list(
				text = "<b>Indicators:</b>",
				font = list(
					size = 16 *
						getOption(
							"talib.chart.scale",
							default = 1
						)
				)
			)
		),
		## legend end

		## title start
		title = list(
			text = title_text,
			font = list(
				size = 20 *
					getOption(
						"talib.chart.scale",
						default = 1
					)
			),
			x = 1,
			xref = "paper",
			xanchor = "right"
		),
		## title end

		...
	)

	## add chart configurations
	## for TA
	plotly::config(
		p = plotly_object,

		## options for support
		## and resistance lines
		modeBarButtonsToAdd = c(
			"drawline",
			"drawrect",
			"eraseshape"
		),

		## remove {plotly} logo
		## to reduce clutter
		##
		## NOTE: Some of the other
		##       buttons is most likely
		##       redundant too. These will be
		##       removed later (TM)
		displaylogo = FALSE
	)
}


## chart titles for
## subplots
add_title <- function(
	x,
	text
) {
	plotly::add_annotations(
		p = x,
		text = text,
		x = 0,
		y = 1,
		xref = "paper",
		yref = "paper",
		showarrow = FALSE,
		font = list(
			size = 16 *
				getOption(
					"talib.chart.scale",
					default = 1
				)
		)
	)
}

#' @title subchart
#'
#' @details
#' A helper function for creating subcharts with prespecified
#' xaxis and x values
#'
#' @param data [data.frame]
#' @param ... arguments passed onto [plotly::plot_ly]
#'
#' @keywords internal
subchart <- function(
	data,
	...
) {
	## main plotly object to
	## be added to the chart
	plotly_object <- plotly::plot_ly(
		data = data,
		x = ~idx,
		...
	)

	## finalize subcart
	plotly_object <- plotly::layout(
		plotly_object,

		## if this part is not added
		## there is mismatch between the
		## main chart and the subscharts
		xaxis = list(
			tickvals = seq_along(data$idx),
			ticktext = data$idx,
			ticmode = "auto"
		)
	)

	## readd configuations
	##
	## NOTE: This is repeated code
	##       from .chart_layout()
	##       - should be consolidated at
	##         some point (TM)
	plotly_object <- plotly::config(
		p = plotly_object,

		## options for support
		## and resistance lines
		modeBarButtonsToAdd = c(
			"drawline",
			"drawrect",
			"eraseshape"
		),

		## remove {plotly} logo
		## to reduce clutter
		##
		## NOTE: Some of the other
		##       buttons is most likely
		##       redundant too. These will be
		##       removed later (TM)
		displaylogo = FALSE
	)

	return(plotly_object)
}

add_ribbons <- function(
	plotly_object,
	data,
	x,
	y,
	ymin,
	ymax,
	color,
	alpha,
	showlegend,
	legendgroup,
	name,
	dash
) {
	## this function adds ribbons
	## to existing plots. It addresses the following
	## issue with plotly::add_ribbons: When adding lines it will
	## box on the right, but not on the left.

	## check if y have been passed
	## and
	y_passed <- as.numeric(
		!missing(y)
	)

	## the name can apply to to each
	## line
	if (length(name) < 3) {
		name <- rep(name, 3)
	}

	if (length(dash) < 3) {
		dash <- rep(dash, 3)
	}

	## add ribbon without lines
	plotly_object <- plotly::add_ribbons(
		p = plotly_object,
		inherit = FALSE,
		data = data,
		x = x,
		ymin = ymin,
		ymax = ymax,
		line = list(
			color = "transparent"
		),
		fillcolor = plotly::toRGB(
			x = color,
			alpha = alpha * 0.5
		),
		showlegend = showlegend,
		legendgroup = legendgroup,
		name = name[1]
	)

	if (!missing(y)) {
		plotly_object <- plotly::add_lines(
			p = plotly_object,
			x = x,
			y = y,
			line = list(
				color = plotly::toRGB(
					x = color,
					alpha = alpha
				),
				dash = dash[1]
			),
			showlegend = FALSE,
			legendgroup = legendgroup,
			inherit = FALSE,
			name = name[1]
		)
	}

	## add lower line to the
	## plot
	plotly_object <- plotly::add_lines(
		p = plotly_object,
		x = x,
		y = ymin,
		line = list(
			color = plotly::toRGB(
				x = color,
				alpha = alpha
			),
			dash = dash[2]
		),
		showlegend = FALSE,
		legendgroup = legendgroup,
		inherit = FALSE,
		name = name[2]
	)

	## add upperline to the
	## plot
	plotly_object <- plotly::add_lines(
		p = plotly_object,
		x = x,
		y = ymax,
		line = list(
			color = plotly::toRGB(
				x = color,
				alpha = alpha
			),
			dash = dash[3]
		),
		showlegend = FALSE,
		legendgroup = legendgroup,
		inherit = FALSE,
		name = name[3]
	)

	## return plot
	return(
		plotly_object
	)
}
