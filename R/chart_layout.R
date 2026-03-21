## script - chart layout functions
## plotly layout decorators for background
## axes - fonts - legends and settings

## ---- background ----

## apply theme colors to the plot
## and panel background
layout_background <- function(
	p
) {
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

## ---- axes ----

## configure x and y axes with
## labels - gridlines and styling
layout_axis <- function(
	p,
	idx
) {
	## if idx is missing
	## pass it as NULL
	if (missing(idx)) {
		idx <- NULL
	}

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
			zerolinecolor = .chart_variables$foreground_color,
			tickformat = "~s"
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

## ---- title ----

## add chart title as an annotation
## positioned at the top-left corner
layout_title <- function(
	p,
	title,
	...
) {
	plotly::add_annotations(
		p = p,
		text = title,
		x = 0,
		y = 1,
		xref = "paper",
		yref = "paper",
		xanchor = "left",
		yanchor = "bottom",
		showarrow = FALSE,
		font = list(
			size = 14 *
				getOption(
					"talib.chart.scale",
					default = 1
				)
		)
	)
}

## ---- font ----

## set font sizes scaled by the
## talib.chart.scale option
layout_font <- function(
	p
) {
	font_scale <- getOption(
		"talib.chart.scale",
		default = 1
	)

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

## ---- legend ----

## configure legend visibility
## and position
layout_legend <- function(
	p
) {
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

## ---- settings ----

## apply range slider - drawing tools
## and remove plotly logo
layout_settings <- function(p) {
	## range slider controls
	range_slider <- getOption(
		"talib.chart.slider",
		default = FALSE
	)
	range_slider_size <- getOption(
		"talib.chart.slider.size",
		default = 0.05
	)

	p <- plotly::layout(
		p = p,
		xaxis = list(
			rangeslider = list(
				visible = range_slider,
				thickness = range_slider_size
			)
		)
	)

	## add drawing tools and
	## remove plotly branding
	plotly::config(
		p = p,
		modeBarButtonsToAdd = c(
			"drawline",
			"drawrect",
			"eraseshape"
		),
		displayModeBar = getOption("talib.chart.modebar", NULL),
		displaylogo = FALSE
	)
}

## ---- colorway ----

## apply the theme colorway to the
## plotly layout for indicator coloring
layout_color <- function(p) {
	plotly::layout(
		p = p,
		colorway = .chart_variables$colorway
	)
}
