## script: Chart Layout
## objective:
##
## construct various helpers
## for <plotly> objects
##
layout_background <- function(
	p,
	theme_element = layout_theme()
) {
	## extract backround and
	## grid colors
	grid_color <- theme_element$grid_color
	paper_bgcolor <- theme_element$paper_bgcolor
	plot_bgcolor <- theme_element$plot_bgcolor

	## apply colors
	plotly::layout(
		p = p,
		paper_bgcolor = .chart_variables$background_color,
		plot_bgcolor = .chart_variables$background_color,
		yaxis = list(
			gridcolor = .chart_variables$gridcolor
		),
		xaxis = list(
			gridcolor = .chart_variables$gridcolor
		)
	)
}

layout_axis <- function(
	p,
	idx
) {
	## if idx is missing
	## pass it as NULL
	if (missing(idx)) {
		idx <- NULL
	}

	## apply layout
	plotly::layout(
		p = p,
		yaxis = list(
			title = '',
			side = "right",
			showline = TRUE,
			mirror = TRUE,
			linecolor = .chart_variables$foreground_color,
			linewidth = 0.1,
			zerolinewidth = 0.1,
			zeroline = FALSE,
			zerolinecolor = .chart_variables$foreground_color
		),
		xaxis = list(
			title = '',
			tickvals = seq_along(idx),
			tickmode = "auto",
			ticktext = idx,
			showline = TRUE,
			mirror = "allticks",
			color = .chart_variables$foreground_color,
			linewidth = 0.1
		)
	)
}

layout_annotate <- function(
	p,
	text,
	x = 0,
	y = 1,
	...
) {
	plotly::add_annotations(
		p = p,
		text = text,
		x = x,
		y = y,
		showarrow = FALSE,
		...
	)
}

layout_title <- function(
	p,
	title,
	...
) {
	## apply layout
	plotly::layout(
		p = p,
		title = list(
			text = title,
			x = 0,
			y = 1,
			xref = "paper",
			yref = "paper",
			xanchor = "left",
			yanchor = "bottom",
			font = list(
				size = 16 *
					getOption(
						"talib.chart.scale",
						default = 1
					)
			)
		)
	)
}


layout_font <- function(
	p,
	theme_element = layout_theme()
) {
	## font color and scale
	font_color <- .chart_variables$text_color
	font_scale <- getOption(
		"talib.chart.scale",
		default = 1
	)

	## apply layout
	plotly::layout(
		p = p,
		title = list(
			font = list(
				14 * font_scale
			)
		),
		font = list(
			size = 10 * font_scale,
			color = .chart_variables$text_color
		),
		legend = list(
			title = list(
				font = list(
					size = 14 * font_scale
				)
			)
		)
	)
}


layout_legend <- function(
	p
) {
	## legend controls
	showlegend <- getOption(
		"talib.chart.legend",
		default = TRUE
	)

	plotly::layout(
		p = p,
		showlegend = showlegend,
		legend = list(
			font = list(size = 8),
			grouptitlefont = list(size = 9),
			itemsizing = "constant",
			maxheight = 0.35,
			bgcolor = "transparent",
			orientation = "v",
			x = 0,
			y = 1,
			yref = "paper",
			xref = "paper",
			yanchor = "top"
		)
	)
}

layout_settings <- function(p) {
	## range sliders
	range_slider <- getOption(
		"talib.chart.slider",
		default = FALSE
	)
	range_slider_size <- getOption(
		"talib.chart.slider.size",
		default = 0.05
	)

	## apply range sliders
	p <- plotly::layout(
		p = p,
		xaxis = list(
			rangeslider = list(
				visible = range_slider,
				thickness = range_slider_size
			)
		)
		## TODO: Understand how this
		## actually works. Its still a
		## black box.
		# margin = list(
		# 	r = 5,
		# 	t = 5,
		# 	l = 5,
		# 	b = 0,
		# 	pad = 0
		# )
	)

	## configurations
	plotly::config(
		p = p,
		## options for support
		## and resistance lines
		modeBarButtonsToAdd = c(
			"drawline",
			"drawrect",
			"eraseshape"
		),
		displayModeBar = getOption("talib.chart.modebar", NULL),

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

layout_color <- function(p) {
	plotly::layout(
		p = p,
		colorway = .chart_variables$colorway
	)
}
