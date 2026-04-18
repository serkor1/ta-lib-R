## script - ggplot2 chart backend
## chart creation - theme - and scale helpers
## for the ggplot2 rendering backend

## ---- dependency checks ----

assert_ggplot2 <- function() {
	if (!requireNamespace("ggplot2", quietly = TRUE)) {
		stop(
			"Package 'ggplot2' is required for the ggplot2 backend. ",
			"Install it with install.packages('ggplot2').",
			call. = FALSE
		)
	}
}

assert_plotly_pkg <- function() {
	if (!requireNamespace("plotly", quietly = TRUE)) {
		stop(
			"Package 'plotly' is required for the plotly backend. ",
			"Install it with install.packages('plotly'), ",
			"or set options(talib.chart.backend = 'ggplot2') ",
			"to use the ggplot2 backend instead.",
			call. = FALSE
		)
	}
}

## ---- chart creation ----

## build a candlestick or OHLC chart
## using ggplot2 as the rendering backend
chart_ggplot2 <- function(
	data,
	type,
	title,
	idx,
	...
) {
	assert_ggplot2()

	## use integer positions for x-axis
	## to ensure consistent alignment between
	## main chart and subcharts
	data$.chart_pos <- seq_len(nrow(data))
	data$direction <- ifelse(
		data$close >= data$open,
		"bull",
		"bear"
	)

	p <- ggplot2::ggplot(
		data,
		ggplot2::aes(
			x = !!as.name(".chart_pos")
		)
	)

	## split data by direction so each geom
	## can use distinct wick - body and border colors
	bull <- data[data$direction == "bull", ]
	bear <- data[data$direction == "bear", ]

	candle_aes <- ggplot2::aes(
		xmin = !!as.name(".chart_pos") - 0.4,
		xmax = !!as.name(".chart_pos") + 0.4,
		ymin = pmin(!!as.name("open"), !!as.name("close")),
		ymax = pmax(!!as.name("open"), !!as.name("close"))
	)

	if (type == "candlestick") {
		## draw wicks as vertical segments
		## from low to high for each direction
		for (side in list(
			list(d = bull, col = .chart_variables$bullish_wick),
			list(d = bear, col = .chart_variables$bearish_wick)
		)) {
			if (nrow(side$d) > 0L) {
				p <- p +
					ggplot2::geom_segment(
						data = side$d,
						ggplot2::aes(
							xend = !!as.name(".chart_pos"),
							y = !!as.name("low"),
							yend = !!as.name("high")
						),
						color = side$col,
						linewidth = 0.4
					)
			}
		}

		## draw candle bodies as filled rectangles
		## with separate fill and border colors
		for (side in list(
			list(
				d = bull,
				fill = .chart_variables$bullish_body,
				border = .chart_variables$bullish_border
			),
			list(
				d = bear,
				fill = .chart_variables$bearish_body,
				border = .chart_variables$bearish_border
			)
		)) {
			if (nrow(side$d) > 0L) {
				p <- p +
					ggplot2::geom_rect(
						data = side$d,
						candle_aes,
						fill = side$fill,
						color = side$border,
						linewidth = 0.3
					)
			}
		}
	} else {
		## OHLC bars - vertical line from low to high
		## with left tick for open and right tick for close
		for (side in list(
			list(d = bull, col = .chart_variables$bullish_wick),
			list(d = bear, col = .chart_variables$bearish_wick)
		)) {
			if (nrow(side$d) > 0L) {
				## high-low vertical bar
				p <- p +
					ggplot2::geom_segment(
						data = side$d,
						ggplot2::aes(
							xend = !!as.name(".chart_pos"),
							y = !!as.name("low"),
							yend = !!as.name("high")
						),
						color = side$col,
						linewidth = 0.5
					)

				## open tick on the left
				p <- p +
					ggplot2::geom_segment(
						data = side$d,
						ggplot2::aes(
							x = !!as.name(".chart_pos") - 0.3,
							xend = !!as.name(".chart_pos"),
							y = !!as.name("open"),
							yend = !!as.name("open")
						),
						color = side$col,
						linewidth = 0.5
					)

				## close tick on the right
				p <- p +
					ggplot2::geom_segment(
						data = side$d,
						ggplot2::aes(
							x = !!as.name(".chart_pos"),
							xend = !!as.name(".chart_pos") + 0.3,
							y = !!as.name("close"),
							yend = !!as.name("close")
						),
						color = side$col,
						linewidth = 0.5
					)
			}
		}
	}

	## construct title text with observation
	## count and date range if available
	state <- .chart_state()
	if (is.integer(state$idx$label)) {
		title_text <- sprintf(
			"%s (N: %d)",
			title,
			nrow(data)
		)
	} else {
		title_text <- sprintf(
			"%s (N: %d, Period: %s)",
			title,
			nrow(data),
			paste(
				state$idx$label[1],
				"-",
				state$idx$label[
					length(state$idx$label)
				]
			)
		)
	}

	## apply theme - title - axes
	p <- p +
		ggplot2::ggtitle(title_text) +
		ggplot_x_scale() +
		ggplot2::scale_y_continuous(
			position = "right",
			name = NULL,
			labels = format_axis_number
		) +
		ggplot_chart_theme()

	## add last value annotation
	p <- add_last_value_gg(p, data)

	## reset colorway counter and color map
	## for subsequent indicator calls
	state$color_idx <- 0L
	state$color_map <- character(0)

	state$main <- p
	wrap_gg(p)
}

## ---- axis formatting ----

## format y-axis labels as human-readable
## numbers - 1K for thousands - 1M for millions - 1B for billions
format_axis_number <- function(x) {
	ifelse(
		is.na(x),
		"",
		ifelse(
			abs(x) >= 1e9,
			paste0(round(x / 1e9, 1), "B"),
			ifelse(
				abs(x) >= 1e6,
				paste0(round(x / 1e6, 1), "M"),
				ifelse(
					abs(x) >= 1e3,
					paste0(round(x / 1e3, 1), "K"),
					format(
						round(x, 2),
						big.mark = "",
						scientific = FALSE
					)
				)
			)
		)
	)
}

## ---- x-axis scale ----

## build the x-axis scale using integer positions
## with labels from the chart environment idx
ggplot_x_scale <- function() {
	idx_labels <- .chart_state()$idx$label
	n <- length(idx_labels)
	xlim <- c(0.5, n + 0.5)

	if (is.null(idx_labels) || is.integer(idx_labels)) {
		ggplot2::scale_x_continuous(
			name = NULL,
			limits = xlim,
			expand = c(0, 0)
		)
	} else {
		ggplot2::scale_x_continuous(
			name = NULL,
			limits = xlim,
			expand = c(0, 0),
			labels = function(breaks) {
				breaks <- as.integer(round(breaks))
				valid <- !is.na(breaks) & breaks >= 1L & breaks <= n
				out <- rep("", length(breaks))
				out[valid] <- as.character(
					idx_labels[breaks[valid]]
				)
				out
			}
		)
	}
}

## ---- theme ----

## apply the ggplot2 chart theme using
## colors from the active chart theme
ggplot_chart_theme <- function() {
	font_scale <- getOption(
		"talib.chart.scale",
		default = 1
	)

	## plotly sizes are CSS px (1px = 1/96in)
	## ggplot2 element_text sizes are pt (1pt = 1/72in)
	px_to_pt <- 72 / 96

	ggplot2::theme(
		## background
		plot.background = ggplot2::element_rect(
			fill = .chart_variables$background_color,
			color = NA
		),
		panel.background = ggplot2::element_rect(
			fill = .chart_variables$background_color,
			color = .chart_variables$foreground_color,
			linewidth = 0.1
		),

		## grid
		panel.grid.major = ggplot2::element_line(
			color = .chart_variables$gridcolor,
			linewidth = 0.2
		),
		panel.grid.minor = ggplot2::element_blank(),

		## text
		text = ggplot2::element_text(
			color = .chart_variables$text_color,
			size = 10 * px_to_pt * font_scale
		),
		plot.title = ggplot2::element_text(
			size = 14 * px_to_pt * font_scale,
			hjust = 0,
			margin = ggplot2::margin(0, 0, 0, 0)
		),
		plot.subtitle = ggplot2::element_text(
			size = 10 * px_to_pt * font_scale,
			margin = ggplot2::margin(0, 0, 2, 0)
		),

		## axes
		axis.text = ggplot2::element_text(
			color = .chart_variables$text_color,
			size = 8 * px_to_pt * font_scale
		),
		axis.ticks = ggplot2::element_line(
			color = .chart_variables$foreground_color,
			linewidth = 0.1
		),
		axis.title = ggplot2::element_blank(),

		## legend
		legend.background = ggplot2::element_rect(
			fill = "transparent"
		),
		legend.key = ggplot2::element_rect(
			fill = "transparent"
		),
		legend.text = ggplot2::element_text(
			size = 8 * px_to_pt * font_scale
		),
		legend.position = if (getOption("talib.chart.legend", TRUE)) {
			"inside"
		} else {
			"none"
		},
		legend.position.inside = c(0, 1),
		legend.justification = c(0, 1),

		## margins
		plot.margin = ggplot2::margin(5, 5, 5, 5)
	)
}
