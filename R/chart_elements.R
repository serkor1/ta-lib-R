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
			size = 16 *
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
	remove_cols = NULL
) {
	## construct last value
	## text
	last_values <- data[
		nrow(data),
		grep(
			x = colnames(data),
			pattern = paste(
				c("idx", remove_cols),
				collapse = "|"
			),
			value = TRUE,
			invert = TRUE,
			ignore.case = TRUE
		)
	]

	value_text <- paste0(
		"<b>",
		colnames(last_values),
		"</b>: ",
		last_values,
		collapse = " "
	)

	plotly::add_annotations(
		p = p,
		text = value_text,
		x = 0,
		y = 1,
		xref = "paper",
		yref = "paper",
		xanchor = "left",
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
