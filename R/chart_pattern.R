pattern <- function(
	p,
	x, # pattern
	high,
	low,
	pattern_name = "Doji",
	agnostic = FALSE
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
			x = x$idx[idx_bear],
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
			x = x$idx[idx_bull],
			y = if (agnostic) {
				high[idx_bull] - offset[idx_bull]
			} else {
				low[idx_bull] - offset[idx_bull]
			},
			type = "scatter",
			mode = "markers+text",
			marker = list(
				symbol = if (agnostic) {
					"triangle-down"
				} else {
					"triangle-up"
				},
				color = if (agnostic) {
					chart_theme$font_color
				} else {
					chart_theme$bull_color
				},
				size = 10
			),
			text = bull_text,
			textposition = if (agnostic) {
				"top center"
			} else {
				"bottom center"
			},
			textfont = list(
				color = if (agnostic) {
					chart_theme$font_color
				} else {
					chart_theme$bull_color
				},
				size = 10
			),
			hoverinfo = "skip",
			name = "Bearish",
			inherit = FALSE,
			showlegend = FALSE
		)
	}

	p <- plotly::layout(
		p,
		## if this part is not added
		## there is mismatch between the
		## main chart and the subscharts
		xaxis = list(
			tickvals = seq_along(x$idx),
			ticktext = x$idx,
			tickmode = "auto"
		)
	)

	return(p)
}
