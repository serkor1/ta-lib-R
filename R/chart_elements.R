## chart titles for
## subplots
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

add_limit <- function(
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

add_last_value <- function(
	p,
	data,
	values_to_extract = c("open", "high", "low", "close")
) {
	## construct last value
	## text
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

	## extract values
	## and names
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
