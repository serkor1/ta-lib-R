## script - indicator chart builders
## constructs plotly and ggplot2 objects
## from indicator traces and layers

## ---- plotly builder ----

## A high-level <plotly> builder for the <plotly>-methods.
## Internal helper - not exposed via Rd.
#' @noRd
build_plotly <- function(
	init,
	traces,
	decorators = list(),
	name,
	data,
	title = NULL,
	...
) {
	UseMethod("build_plotly")
}

#' @export
build_plotly.plotly <- function(
	init,
	traces,
	decorators = list(),
	name,
	data,
	title = NULL,
	...
) {
	## fallback - retrieve data from the
	## calling environment if not passed
	if (missing(data)) {
		data <- get(
			"constructed_indicator",
			parent.frame()
		)
	}

	## replace missing names
	## with title
	if (missing(name) | is.null(name)) {
		name <- title
	}

	## strip lookback NAs from the
	## beginning of the indicator data
	if (!is.null(attr(data, "lookback", TRUE))) {
		data <- data[-(1:attr(data, "lookback", TRUE)), ]
	}

	## default trace properties for
	## non-reference-line traces
	default_trace <- list(
		type = "scatter",
		mode = "lines",
		showlegend = TRUE,
		inherit = FALSE,

		## name and legendgroup
		## has to be unique
		name = name,
		legendgroup = name,
		legendgrouptitle = list(
			text = if (missing(title)) {
				name
			} else {
				title
			}
		),
		data = data,
		x = ~idx
	)

	## identify which traces are
	## reference lines - these skip defaults
	is_line <- vapply(
		traces,
		inherits,
		logical(1),
		"plotly_line"
	)

	non_line <- which(!is_line)

	## apply defaults only to
	## non-reference-line traces
	if (length(non_line) > 0) {
		traces[non_line] <- lapply(
			traces[non_line],
			function(tr) {
				utils::modifyList(
					default_trace,
					tr,
					keep.null = TRUE
				)
			}
		)
	}

	## build the plotly object by
	## reducing all traces onto init
	plotly_object <- Reduce(
		f = function(acc, tr) {
			do.call(
				plotly::add_trace,
				c(list(acc), tr)
			)
		},
		x = traces,
		init = init
	)

	## add subchart title if this is
	## attached to an existing chart
	if (!is.null(title) && !is.null(.chart_state()$main)) {
		plotly_object <- add_title(
			plotly_object,
			text = title
		)
	}

	## apply indicator-specific
	## decorators if provided
	if (!is.empty(decorators)) {
		plotly_object <- Reduce(
			f = function(p, f) f(p),
			x = decorators,
			init = plotly_object
		)
	}

	## apply common layout decorators
	## for background - axis and legend
	fns <- list(
		function(p) layout_background(p),
		function(p) layout_axis(p, data$idx),
		function(p) layout_legend(p)
	)

	Reduce(
		f = function(p, f) f(p),
		x = fns,
		init = plotly_object
	)
}

## ---- ggplot2 builder ----

## build ggplot2 indicator layers
## with dynamic color cycling from the active theme
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
	## main chart overlays do - fresh subcharts do not
	needs_scales <- length(init$scales$scales) == 0L

	## strip lookback NAs from the
	## beginning of the indicator data
	lookback <- attr(data, "lookback", TRUE)
	if (is.null(lookback) || is.na(lookback)) {
		lookback <- 0L
	}
	if (lookback > 0L) {
		data <- data[-(1:lookback), , drop = FALSE]
	}

	## add position column aligned
	## with main chart x-axis
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
	state <- .chart_state()
	color_idx <- state$color_idx %nn% 0L
	color_map <- if (needs_scales) {
		character(0)
	} else {
		state$color_map %nn% character(0)
	}

	## track whether fill scale has been used
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
				## ribbon geom - no legend entry
				## no color cycling
				y_upper <- layer$y_upper
				y_lower <- layer$y_lower
				ribbon_color <- layer[["color"]] %nn%
					if (length(color_map) > 0L) {
						unname(.tail(color_map, 1L))
					} else {
						colorway[1L]
					}
				ribbon_alpha <- layer$alpha %nn% 0.15

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
							x = !!as.name(".chart_pos"),
							ymin = !!as.name(y_lower),
							ymax = !!as.name(y_upper)
						),
						fill = ribbon_color,
						alpha = ribbon_alpha,
						na.rm = TRUE
					)
			} else {
				## determine legend name - prefer layer-level
				## then per-call name then column name
				layer_name <- layer$name %nn% name %nn% y_col

				## reuse color for repeated legend names
				## eg combined indicators like Bollinger Bands
				if (layer_name %in% names(color_map)) {
					line_color <- color_map[[layer_name]]
				} else {
					color_idx <- color_idx + 1L
					line_color <- layer[["color"]] %nn%
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
								x = !!as.name(".chart_pos"),
								y = !!as.name(y_col),
								colour = !!as.name(".legend")
							),
							linewidth = 0.5,
							na.rm = TRUE
						)
				} else if (geom == "bar") {
					if (!is.null(layer$direction)) {
						## bar with directional coloring
						## eg MACD histogram
						p <- p +
							ggplot2::geom_col(
								data = data,
								ggplot2::aes(
									x = !!as.name(".chart_pos"),
									y = !!as.name(y_col),
									fill = !!as.name(layer$direction)
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
						## plain bar without direction
						p <- p +
							ggplot2::geom_col(
								data = data,
								ggplot2::aes(
									x = !!as.name(".chart_pos"),
									y = !!as.name(y_col)
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
								x = !!as.name(".chart_pos"),
								y = !!as.name(y_col),
								colour = !!as.name(".legend")
							),
							size = 6 * 25.4 / 96,
							na.rm = TRUE
						)
				}
			}
		}
	}

	## persist colorway counter so subsequent
	## indicator calls continue cycling
	state$color_idx <- color_idx

	## add colour scale for legend entries
	if (length(color_map) > 0L) {
		## remove existing colour scale to
		## avoid ggplot2 replacement warning
		p$scales$scales <- Filter(
			function(s) !("colour" %in% s$aesthetics),
			p$scales$scales
		)
		p <- p +
			ggplot2::scale_colour_manual(
				name = NULL,
				values = color_map,
				breaks = names(color_map)
			)
	}

	## persist color map for main chart overlays
	if (!needs_scales) {
		state$color_map <- color_map
	}

	## add title for subcharts
	if (!is.null(title) && !is.null(state$main)) {
		p <- p + ggplot2::ggtitle(title)
	}

	## apply indicator-specific decorators
	if (length(decorators) > 0) {
		for (fn in decorators) {
			p <- fn(p)
		}
	}

	## apply common theme and scales
	## only add scales for fresh subcharts
	## not main chart overlays
	if (needs_scales) {
		p <- p +
			ggplot_x_scale() +
			ggplot2::scale_y_continuous(
				position = "right",
				name = NULL,
				labels = format_axis_number
			)
	}
	p <- p + ggplot_chart_theme()

	p
}
