.chart_layout <- function(
	x,
	title_text,
	idx = NULL,
	...
) {
	## extract chart theme
	## from R/chart_options.R
	chart_theme <- .chart_theme()

	## hardcoded layout elements
	## and added flexibility in ellipsis
	plotly_object <- plotly::layout(
		p = x,
		paper_bgcolor = chart_theme$paper_bgcolor,
		plot_bgcolor = chart_theme$plot_bgcolor,
		font = list(
			size = 14 *
				getOption(
					"talib.chart.scale",
					default = 1
				),
			color = chart_theme$font_color
		),
		yaxis = list(
			title = '',
			gridcolor = chart_theme$grid_color
		),
		xaxis = list(
			title = '',
			gridcolor = chart_theme$grid_color,
			rangeslider = list(
				visible = getOption(
					"talib.chart.slider",
					default = FALSE
				),
				thickness = getOption(
					"talib.chart.slider.size",
					default = 0.05
				)
			),
			tickvals = seq_along(idx),
			tickmode = "auto",
			ticktext = idx
		),

		## legend start
		showlegend = getOption(
			"talib.chart.legend",
			default = TRUE
		),
		legend = list(
			orientation = 'h',
			x = 0,
			y = 100,
			yref = "container",
			title = list(
				text = "<b>Indicators:</b>",
				font = list(
					size = 16 *
						getOption(
							"talib.chart.scale",
							default = 1
						)
				)
			)
		),
		## legend end

		## title start
		title = list(
			text = title_text,
			font = list(
				size = 20 *
					getOption(
						"talib.chart.scale",
						default = 1
					)
			),
			x = 1,
			xref = "paper",
			xanchor = "right"
		),
		## title end

		...
	)

	## add chart configurations
	## for TA
	plotly::config(
		p = plotly_object,

		## options for support
		## and resistance lines
		modeBarButtonsToAdd = c(
			"drawline",
			"drawrect",
			"eraseshape"
		),

		## remove {plotly} logo
		## to reduce clutter
		##
		## NOTE: Some of the other
		##       buttons is most likely
		##       redundant too. These will be
		##       removed later (TM)
		displaylogo = FALSE
	)
}


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
