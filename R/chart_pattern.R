## script - candlestick pattern markers
## adds triangle markers and labels to charts
## for detected candlestick patterns

## ---- plotly patterns ----

## add pattern markers to a plotly chart
## bearish patterns get down-triangles above the candle
## bullish patterns get up-triangles below the candle
pattern_ly <- function(
	p,
	x,
	high,
	low,
	pattern_name = "Doji",
	agnostic = FALSE
) {
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

	## add bearish markers
	## above the candle
	if (length(idx_bear)) {
		p <- plotly::add_trace(
			p = p,
			x = x$idx[idx_bear],
			y = high[idx_bear] + offset[idx_bear],
			type = "scatter",
			mode = "markers+text",
			marker = list(
				symbol = "triangle-down",
				color = .chart_variables$bearish_body,
				size = 10
			),
			text = bear_text,
			textposition = "top center",
			textfont = list(color = .chart_variables$bearish_body, size = 10),
			hoverinfo = "skip",
			name = "Bearish",
			inherit = FALSE,
			showlegend = FALSE
		)
	}

	## add bullish markers below the candle
	## agnostic mode uses inverted triangle above
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
					.chart_variables$foreground_color
				} else {
					.chart_variables$bullish_body
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
					.chart_variables$foreground_color
				} else {
					.chart_variables$bullish_body
				},
				size = 10
			),
			hoverinfo = "skip",
			name = "Bearish",
			inherit = FALSE,
			showlegend = FALSE
		)
	}

	## realign x-axis to prevent
	## mismatch between main chart and subcharts
	p <- plotly::layout(
		p,
		xaxis = list(
			tickvals = seq_along(x$idx),
			ticktext = x$idx,
			tickmode = "auto"
		)
	)

	return(p)
}

## ---- ggplot2 patterns ----

## add pattern markers to a ggplot2 chart
## uses triangle point shapes - 24 up and 25 down
pattern_gg <- function(
	p,
	x,
	high,
	low,
	pattern_name = "Doji",
	agnostic = FALSE
) {
	## locate bull and bear indices
	idx_bull <- which(x[[1]] > 0L)
	idx_bear <- which(x[[1]] < 0L)

	## convert idx labels to integer chart positions
	## the ggplot2 backend uses integer positions on x-axis
	chart_pos <- match(x$idx, .chart_state()$idx$label)

	## offset markers from candle body
	## so they do not overlap with wicks
	offset <- 0.15 * (high - low)

	## add bearish markers above the candle
	if (length(idx_bear) > 0) {
		bear_data <- data.frame(
			.chart_pos = chart_pos[idx_bear],
			y = high[idx_bear] + offset[idx_bear],
			label = pattern_name
		)

		p <- p +
			ggplot2::geom_point(
				data = bear_data,
				ggplot2::aes(
					x = !!as.name(".chart_pos"),
					y = !!as.name("y")
				),
				shape = 25,
				fill = .chart_variables$bearish_body,
				color = .chart_variables$bearish_body,
				size = 10 * 25.4 / 96
			)

		p <- p +
			ggplot2::geom_text(
				data = bear_data,
				ggplot2::aes(
					x = !!as.name(".chart_pos"),
					y = !!as.name("y"),
					label = !!as.name("label")
				),
				vjust = -1,
				color = .chart_variables$bearish_body,
				size = 10 * 25.4 / 96
			)
	}

	## add bullish markers below the candle
	## agnostic mode uses inverted triangle above
	if (length(idx_bull) > 0) {
		bull_data <- data.frame(
			.chart_pos = chart_pos[idx_bull],
			y = if (agnostic) {
				high[idx_bull] - offset[idx_bull]
			} else {
				low[idx_bull] - offset[idx_bull]
			},
			label = pattern_name
		)

		marker_color <- if (agnostic) {
			.chart_variables$foreground_color
		} else {
			.chart_variables$bullish_body
		}

		p <- p +
			ggplot2::geom_point(
				data = bull_data,
				ggplot2::aes(
					x = !!as.name(".chart_pos"),
					y = !!as.name("y")
				),
				shape = if (agnostic) 25 else 24,
				fill = marker_color,
				color = marker_color,
				size = 10 * 25.4 / 96
			)

		p <- p +
			ggplot2::geom_text(
				data = bull_data,
				ggplot2::aes(
					x = !!as.name(".chart_pos"),
					y = !!as.name("y"),
					label = !!as.name("label")
				),
				vjust = if (agnostic) -1 else 2,
				color = marker_color,
				size = 10 * 25.4 / 96
			)
	}

	p
}
