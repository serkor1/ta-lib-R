## chart theme
layout_theme <- .chart_theme <- function() {
	## bull or bear colors
	if (getOption("talib.chart.deficiency", default = FALSE)) {
		bull_color = "#5d8ca8"
		bear_color = "#d3ba68"
	} else {
		bull_color = "#65a479"
		bear_color = "#d5695d"
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
			paper_bgcolor = '#E3E3E3',
			plot_bgcolor = '#E3E3E3',
			font_color = '#A3A3A3',
			threshold_color = '#8A8C90',
			grid_color = '#D3D3D3',
			bull_color = bull_color,
			bear_color = bear_color
		)
	}
}
