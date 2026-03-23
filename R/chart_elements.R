## script - chart element functions
## annotations and decorations for both backends

## ---- plotly elements ----

## add subtitle annotation for subchart panels
## positioned at the top-left corner
add_title <- function(
	x,
	text
) {
	plotly::add_annotations(
		p = x,
		text = text,
		x = 0,
		y = 1,
		xref = "paper",
		yref = "paper",
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

## set fixed y-axis limits on a plotly subchart
## used for bounded indicators - eg RSI 0 to 100
add_limit_ly <- function(
	p,
	y_range
) {
	plotly::layout(
		p = p,
		yaxis = list(
			range = c(y_range[1], y_range[2])
		)
	)
}

## add OHLC last-value annotation
## displayed at the top-right corner of the main chart
add_last_value_ly <- function(
	p,
	data,
	values_to_extract = c("open", "high", "low", "close")
) {
	## extract the last row for the
	## relevant OHLC columns
	last_values <- data[
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

	## format each value with its column name
	values <- vapply(
		last_values,
		function(col) col[[1]],
		numeric(1)
	)

	ohlc <- names(values)

	value_text <- paste(
		sprintf("<b>%s:</b> %.2f", ohlc, values),
		collapse = " "
	)

	plotly::add_annotations(
		p = p,
		text = value_text,
		x = 1,
		y = 1,
		xref = "paper",
		yref = "paper",
		xanchor = "right",
		yanchor = "bottom",
		showarrow = FALSE,
		font = list(
			size = 10 *
				getOption(
					"talib.chart.scale",
					default = 1
				)
		)
	)
}

## ---- ggplot2 elements ----

## add last-value annotation as subtitle
## for the ggplot2 backend - shown at top-right
## uses plotmath expressions for bold labels
##
## when name is provided it is stored as metadata
## on the plot so merge_subchart_ggplot() can build
## a combined subtitle for multi-indicator panels
add_last_value_gg <- function(
	p,
	data,
	values_to_extract = c("open", "high", "low", "close"),
	name = NULL
) {
	## extract the last row for the
	## relevant columns
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

	## format values as a single line
	values <- vapply(
		last_row,
		function(col) col[[1]],
		numeric(1)
	)

	## store metadata for merge_subchart_ggplot()
	## to reconstruct a combined subtitle
	if (!is.null(name)) {
		attr(p, "talib_last_value") <- list(
			name = name,
			values = values
		)
	}

	## build plotmath expression with bold labels
	## renders as: open: 42312.50  high: 43000.00
	## with column names in bold
	parts <- Map(
		function(nm, val) {
			bquote(bold(.(paste0(nm, ":"))) ~ .(sprintf("%.2f", val)))
		},
		names(values),
		unname(values)
	)

	value_expr <- as.expression(
		if (length(parts) == 1L) {
			parts[[1L]]
		} else {
			Reduce(function(a, b) bquote(.(a) ~ ~ .(b)), parts)
		}
	)

	p +
		ggplot2::labs(subtitle = value_expr) +
		ggplot2::theme(
			plot.subtitle = ggplot2::element_text(
				hjust = 1,
				size = 10 * (72 / 96) * getOption("talib.chart.scale", 1),
				color = .chart_variables$text_color
			)
		)
}

## set fixed y-axis limits on a ggplot2 subchart
## used for bounded indicators - eg RSI 0 to 100
add_limit_gg <- function(p, y_range) {
	p +
		ggplot2::coord_cartesian(
			ylim = c(y_range[1], y_range[2])
		)
}
