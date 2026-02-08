## chart theme
layout_theme <- .chart_theme <- function() {
	## bull or bear colors
	if (getOption("talib.chart.deficiency", default = FALSE)) {
		bull_color = "#5d8ca8"
		bear_color = "#d3ba68"
	} else {
		bull_color = "#4D4D4D"
		bear_color = "#A9A9A9"
	}

	if (getOption("talib.chart.dark", default = TRUE)) {
		list(
			paper_bgcolor = '#2b3139',
			plot_bgcolor = '#2b3139',
			font_color = '#848e9c',
			threshold_color = '#9499A0',
			grid_color = '#40454c',
			bull_color = bull_color,
			bear_color = bear_color
		)
	} else {
		list(
			paper_bgcolor = '#FFFFFF',
			plot_bgcolor = '#FFFFFF',
			font_color = '#333333',
			threshold_color = '##333333',
			grid_color = '#FFFFFF',
			bull_color = bull_color,
			bear_color = bear_color
		)
	}
}
