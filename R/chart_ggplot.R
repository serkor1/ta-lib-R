## ggplot2 backend for the charting system
##
## All ggplot2-specific chart infrastructure lives here.
## This parallels the plotly functions in chart_build.R,
## chart_elements.R, chart_layout.R, and helper.R.

## null-coalescing operator
`%nn%` <- function(x, y) if (is.null(x)) y else x

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


## ---- chart creation ----

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
			x = .data[[".chart_pos"]]
		)
	)

	## split data by direction so each geom
	## can use distinct wick, body, and border colors
	bull <- data[data$direction == "bull", ]
	bear <- data[data$direction == "bear", ]

	candle_aes <- ggplot2::aes(
		xmin = .data[[".chart_pos"]] - 0.4,
		xmax = .data[[".chart_pos"]] + 0.4,
		ymin = pmin(.data[["open"]], .data[["close"]]),
		ymax = pmax(.data[["open"]], .data[["close"]])
	)

	if (type == "candlestick") {
		## wicks
		for (side in list(
			list(d = bull, col = .chart_variables$bullish_wick),
			list(d = bear, col = .chart_variables$bearish_wick)
		)) {
			if (nrow(side$d) > 0L) {
				p <- p +
					ggplot2::geom_segment(
						data = side$d,
						ggplot2::aes(
							xend = .data[[".chart_pos"]],
							y = .data[["low"]],
							yend = .data[["high"]]
						),
						color = side$col,
						linewidth = 0.4
					)
			}
		}

		## body fill + border
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
		## OHLC bars
		for (side in list(
			list(d = bull, col = .chart_variables$bullish_wick),
			list(d = bear, col = .chart_variables$bearish_wick)
		)) {
			if (nrow(side$d) > 0L) {
				## high-low
				p <- p +
					ggplot2::geom_segment(
						data = side$d,
						ggplot2::aes(
							xend = .data[[".chart_pos"]],
							y = .data[["low"]],
							yend = .data[["high"]]
						),
						color = side$col,
						linewidth = 0.5
					)

				## open tick (left)
				p <- p +
					ggplot2::geom_segment(
						data = side$d,
						ggplot2::aes(
							x = .data[[".chart_pos"]] - 0.3,
							xend = .data[[".chart_pos"]],
							y = .data[["open"]],
							yend = .data[["open"]]
						),
						color = side$col,
						linewidth = 0.5
					)

				## close tick (right)
				p <- p +
					ggplot2::geom_segment(
						data = side$d,
						ggplot2::aes(
							x = .data[[".chart_pos"]],
							xend = .data[[".chart_pos"]] + 0.3,
							y = .data[["close"]],
							yend = .data[["close"]]
						),
						color = side$col,
						linewidth = 0.5
					)
			}
		}
	}

	## construct title text
	if (is.integer(.chart_environment$idx$label)) {
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
				.chart_environment$idx$label[1],
				"-",
				.chart_environment$idx$label[
					length(.chart_environment$idx$label)
				]
			)
		)
	}

	## apply theme, title, axes
	p <- p +
		ggplot2::ggtitle(title_text) +
		ggplot_x_scale() +
		ggplot2::scale_y_continuous(
			position = "right",
			name = NULL
		) +
		ggplot_chart_theme()

	## add last value annotation
	p <- add_last_value_gg(p, data)

	## reset colorway counter and color map for indicators
	.chart_environment$color_idx <- 0L
	.chart_environment$color_map <- character(0)

	.chart_environment$main <- p
	p
}

## ---- chart assembly ----

assemble_ggplot2 <- function() {
	panels <- c(
		list(.chart_environment$main),
		.chart_environment$sub
	)
	n <- length(panels)

	## single panel: return as-is
	if (n == 1L) {
		.chart_environment$chart <- panels[[1]]
		return(panels[[1]])
	}

	## set panel heights
	main_h <- getOption("talib.chart.main", 0.7)
	heights <- c(
		main_h,
		rep(
			(1 - main_h) / (n - 1),
			n - 1
		)
	)

	## remove x-axis elements from all
	## panels except the bottom one
	for (i in seq_len(n - 1)) {
		panels[[i]] <- panels[[i]] +
			ggplot2::theme(
				axis.text.x = ggplot2::element_blank(),
				axis.ticks.x = ggplot2::element_blank(),
				plot.margin = ggplot2::margin(2, 5, 0, 5)
			)
	}

	## convert to grobs and align column widths
	## so that y-axes line up across panels.
	## use a null device to prevent Rplots.pdf
	## from being created in non-interactive sessions
	grDevices::pdf(nullfile())
	dev_null <- grDevices::dev.cur()
	on.exit(grDevices::dev.off(dev_null), add = TRUE)
	grobs <- lapply(panels, ggplot2::ggplotGrob)
	max_widths <- do.call(
		grid::unit.pmax,
		lapply(grobs, function(g) g$widths)
	)
	grobs <- lapply(grobs, function(g) {
		g$widths <- max_widths
		g
	})

	## assemble into a talib_chart object
	fig <- structure(
		list(
			grobs = grobs,
			heights = heights,
			n = n
		),
		class = "talib_chart"
	)

	.chart_environment$chart <- fig
	fig
}

#' @export
print.talib_chart <- function(x, ...) {
	grid::grid.newpage()

	layout <- grid::grid.layout(
		nrow = x$n,
		ncol = 1,
		heights = grid::unit(x$heights, "null")
	)

	grid::pushViewport(
		grid::viewport(layout = layout)
	)

	for (i in seq_len(x$n)) {
		grid::pushViewport(
			grid::viewport(layout.pos.row = i)
		)
		grid::grid.draw(x$grobs[[i]])
		grid::popViewport()
	}

	grid::popViewport()
	invisible(x)
}

## ---- build ----

build_ggplot <- function(
	init,
	layers,
	decorators = list(),
	name,
	data,
	title = NULL,
	...
) {
	## check if init already has scales
	## (main chart overlays do, fresh subcharts don't)
	needs_scales <- length(init$scales$scales) == 0L

	## strip lookback NAs
	lookback <- attr(data, "lookback", TRUE)
	if (is.null(lookback) || is.na(lookback)) {
		lookback <- 0L
	}
	if (lookback > 0L) {
		data <- data[-(1:lookback), , drop = FALSE]
	}

	## add position column aligned with main chart
	data$.chart_pos <- seq.int(
		lookback + 1L,
		lookback + nrow(data)
	)

	## replace missing name
	if (missing(name) || is.null(name)) {
		name <- title
	}

	p <- init
	colorway <- .chart_variables$colorway
	color_idx <- .chart_environment$color_idx %nn% 0L
	color_map <- if (needs_scales) {
		character(0)
	} else {
		.chart_environment$color_map %nn% character(0)
	}

	## track whether fill/color scales have been used
	## to avoid duplicate scale errors
	has_fill_scale <- FALSE

	for (layer in layers) {
		if (inherits(layer, "ggplot_line")) {
			## horizontal reference line
			p <- p +
				ggplot2::geom_hline(
					yintercept = layer$value,
					linetype = if (layer$dash) "dotted" else "solid",
					color = .chart_variables$threshold_color,
					linewidth = 0.3
				)
		} else {
			geom <- layer$geom %nn% "line"
			y_col <- layer$y

			## convert formula to string
			if (is.language(y_col)) {
				y_col <- all.vars(y_col)
			}

			if (geom == "ribbon") {
				## ribbon: no legend entry, no color cycling
				y_upper <- layer$y_upper
				y_lower <- layer$y_lower
				ribbon_color <- layer$color %nn% "steelblue"
				ribbon_alpha <- layer$alpha %nn% 0.2

				if (is.language(y_upper)) {
					y_upper <- all.vars(y_upper)
				}
				if (is.language(y_lower)) {
					y_lower <- all.vars(y_lower)
				}

				p <- p +
					ggplot2::geom_ribbon(
						data = data,
						ggplot2::aes(
							x = .data[[".chart_pos"]],
							ymin = .data[[y_lower]],
							ymax = .data[[y_upper]]
						),
						fill = ribbon_color,
						alpha = ribbon_alpha,
						na.rm = TRUE
					)
			} else {
				## legend name: prefer layer-level, then
				## per-call name, then column name
				layer_name <- layer$name %nn% name %nn% y_col

				## reuse color for repeated legend names
				## (combined indicators like Bollinger Bands)
				if (layer_name %in% names(color_map)) {
					line_color <- color_map[[layer_name]]
				} else {
					color_idx <- color_idx + 1L
					line_color <- layer$color %nn%
						colorway[
							((color_idx - 1L) %% length(colorway)) + 1L
						]
					color_map[layer_name] <- line_color
				}

				## layer-local data with legend label
				layer_data <- data
				layer_data[[".legend"]] <- layer_name

				if (geom == "line") {
					p <- p +
						ggplot2::geom_line(
							data = layer_data,
							ggplot2::aes(
								x = .data[[".chart_pos"]],
								y = .data[[y_col]],
								colour = .data[[".legend"]]
							),
							linewidth = 0.5,
							na.rm = TRUE
						)
				} else if (geom == "bar") {
					if (!is.null(layer$direction)) {
						p <- p +
							ggplot2::geom_col(
								data = data,
								ggplot2::aes(
									x = .data[[".chart_pos"]],
									y = .data[[y_col]],
									fill = .data[[layer$direction]]
								),
								width = 0.8,
								na.rm = TRUE
							)
						if (!has_fill_scale) {
							bull_col <- if (!is.null(layer$colors)) {
								layer$colors[1]
							} else {
								.chart_variables$bullish_body
							}
							bear_col <- if (!is.null(layer$colors)) {
								layer$colors[2]
							} else {
								.chart_variables$bearish_body
							}
							p <- p +
								ggplot2::scale_fill_manual(
									values = c(
										"FALSE" = bull_col,
										"TRUE" = bear_col
									),
									guide = "none"
								)
							has_fill_scale <- TRUE
						}
					} else {
						p <- p +
							ggplot2::geom_col(
								data = data,
								ggplot2::aes(
									x = .data[[".chart_pos"]],
									y = .data[[y_col]]
								),
								fill = line_color,
								width = 0.8,
								na.rm = TRUE
							)
					}
				} else if (geom == "point") {
					p <- p +
						ggplot2::geom_point(
							data = layer_data,
							ggplot2::aes(
								x = .data[[".chart_pos"]],
								y = .data[[y_col]],
								colour = .data[[".legend"]]
							),
							size = 1.5,
							na.rm = TRUE
						)
				}
			}
		}
	}

	## persist colorway counter so subsequent
	## indicator calls continue cycling
	.chart_environment$color_idx <- color_idx

	## add colour scale for legend entries
	if (length(color_map) > 0L) {
		## remove existing colour scale to
		## avoid ggplot2 replacement warning
		p$scales$scales <- Filter(
			function(s) !("colour" %in% s$aesthetics),
			p$scales$scales
		)
		p <- p + ggplot2::scale_colour_manual(
			name = NULL,
			values = color_map,
			breaks = names(color_map)
		)
	}

	## persist color map for main chart overlays
	if (!needs_scales) {
		.chart_environment$color_map <- color_map
	}

	## add title for subcharts
	if (!is.null(title) && !is.null(.chart_environment$main)) {
		p <- p + ggplot2::ggtitle(title)
	}

	## apply decorators
	if (length(decorators) > 0) {
		for (fn in decorators) {
			p <- fn(p)
		}
	}

	## apply common theme; only add scales
	## for fresh subcharts (not main chart overlays)
	if (needs_scales) {
		p <- p +
			ggplot_x_scale() +
			ggplot2::scale_y_continuous(
				position = "right",
				name = NULL
			)
	}
	p <- p + ggplot_chart_theme()

	p
}

## ---- helpers ----

ggplot_init <- function(...) {
	assert_ggplot2()
	ggplot2::ggplot()
}

ggplot_line <- function(value, length, dash = TRUE) {
	x <- list(
		value = value,
		dash = dash
	)
	class(x) <- "ggplot_line"
	x
}

## ---- x-axis scale ----

ggplot_x_scale <- function() {
	idx_labels <- .chart_environment$idx$label

	if (is.null(idx_labels) || is.integer(idx_labels)) {
		ggplot2::scale_x_continuous(
			name = NULL
		)
	} else {
		n <- length(idx_labels)
		ggplot2::scale_x_continuous(
			name = NULL,
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

ggplot_chart_theme <- function() {
	font_scale <- getOption(
		"talib.chart.scale",
		default = 1
	)

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
			size = 10 * font_scale
		),
		plot.title = ggplot2::element_text(
			size = 14 * font_scale,
			hjust = 0,
			margin = ggplot2::margin(0, 0, 0, 0)
		),
		plot.subtitle = ggplot2::element_text(
			margin = ggplot2::margin(0, 0, 2, 0)
		),

		## axes
		axis.text = ggplot2::element_text(
			color = .chart_variables$text_color,
			size = 8 * font_scale
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
			size = 8 * font_scale
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

## ---- elements ----

add_last_value_gg <- function(
	p,
	data,
	values_to_extract = c("open", "high", "low", "close")
) {
	last_row <- data[
		nrow(data),
		grep(
			x = colnames(data),
			pattern = paste0(values_to_extract, collapse = "|"),
			value = TRUE,
			invert = FALSE,
			ignore.case = TRUE
		),
		drop = FALSE
	]

	values <- vapply(
		last_row,
		function(col) col[[1]],
		numeric(1)
	)

	value_text <- paste(
		sprintf("%s: %.2f", names(values), values),
		collapse = "  "
	)

	p +
		ggplot2::labs(subtitle = value_text) +
		ggplot2::theme(
			plot.subtitle = ggplot2::element_text(
				hjust = 1,
				size = 10 * getOption("talib.chart.scale", 1),
				color = .chart_variables$text_color
			)
		)
}

add_limit_gg <- function(p, y_range) {
	p +
		ggplot2::coord_cartesian(
			ylim = c(y_range[1], y_range[2])
		)
}

## ---- pattern ----

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

	## calculate offsets
	offset <- 0.15 * (high - low)

	## add bearish markers
	if (length(idx_bear) > 0) {
		bear_data <- data.frame(
			.chart_pos = x$idx[idx_bear],
			y = high[idx_bear] + offset[idx_bear],
			label = pattern_name
		)

		p <- p +
			ggplot2::geom_point(
				data = bear_data,
				ggplot2::aes(
					x = .data[[".chart_pos"]],
					y = .data[["y"]]
				),
				shape = 25,
				fill = .chart_variables$bearish_body,
				color = .chart_variables$bearish_body,
				size = 2.5
			)

		p <- p +
			ggplot2::geom_text(
				data = bear_data,
				ggplot2::aes(
					x = .data[[".chart_pos"]],
					y = .data[["y"]],
					label = .data[["label"]]
				),
				vjust = -1,
				color = .chart_variables$bearish_body,
				size = 2.5
			)
	}

	## add bullish markers
	if (length(idx_bull) > 0) {
		bull_data <- data.frame(
			.chart_pos = x$idx[idx_bull],
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
					x = .data[[".chart_pos"]],
					y = .data[["y"]]
				),
				shape = if (agnostic) 25 else 24,
				fill = marker_color,
				color = marker_color,
				size = 2.5
			)

		p <- p +
			ggplot2::geom_text(
				data = bull_data,
				ggplot2::aes(
					x = .data[[".chart_pos"]],
					y = .data[["y"]],
					label = .data[["label"]]
				),
				vjust = if (agnostic) -1 else 2,
				color = marker_color,
				size = 2.5
			)
	}

	p
}
