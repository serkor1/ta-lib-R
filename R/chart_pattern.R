pattern <- function(
	p,
	x, # pattern
	high,
	low,
	pattern_name = "Doji"
) {
	## chart theme controls
	chart_theme <- .chart_theme()

	## locate bull and
	## bear indices
	idx_bull <- which(x[[1]] > 0L)
	idx_bear <- which(x[[1]] < 0L)

	## add pattern names
	## based on idx
	bull_text <- rep(pattern_name, length(idx_bull))
	bear_text <- rep(pattern_name, length(idx_bear))

	## calculate offsets
	## to place the markers
	offset <- 0.15 * (high - low)

	## add patterns
	## to the chart
	if (length(idx_bear)) {
		p <- plotly::add_trace(
			p = p,
			x = idx_bear,
			y = high[idx_bear] + offset[idx_bear],
			type = "scatter",
			mode = "markers+text",
			marker = list(
				symbol = "triangle-down",
				color = chart_theme$bear_color,
				size = 10
			),
			text = bear_text,
			textposition = "top center",
			textfont = list(color = chart_theme$bear_color, size = 10),
			hoverinfo = "skip",
			name = "Bearish",
			inherit = FALSE,
			showlegend = FALSE
		)
	}

	if (length(idx_bull)) {
		p <- plotly::add_trace(
			p = p,
			x = idx_bull,
			y = low[idx_bull] - offset[idx_bull],
			type = "scatter",
			mode = "markers+text",
			marker = list(
				symbol = "triangle-up",
				color = chart_theme$bull_color,
				size = 10
			),
			text = bull_text,
			textposition = "bottom center",
			textfont = list(color = chart_theme$bull_color, size = 10),
			hoverinfo = "skip",
			name = "Bearish",
			inherit = FALSE,
			showlegend = FALSE
		)
	}

	return(p)
}
