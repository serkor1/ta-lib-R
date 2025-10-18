#' @export
#' @family Charting
#' @author Serkan Korkmaz
#'
#' @title Chart
#'
#' @description
#' The [chart]-function is a generic S3 function for charting OHLC series as either
#' candlesticks or 'traditional' OHLC-bars. The function is a high-level wrapper of [plotly::plot_ly] with
#' predefined OHLC values based on the input series.
#'
#' @details
#' The function uses various controlable options:
#'
#' \describe{
#'  \item{talib.deficiency <[logical]>}{`FALSE` by default. If `TRUE` it uses colorblind-friendly colors.}
#'  \item{talib.chart.dark <[logical]>}{`TRUE` by default. If `FALSE` it charting is done in light mode.}
#'  \item{talib.chart.slider <[logical]>}{`FALSE` by default. If `TRUE` a `rangeslider` is added to the chart.}
#'  \item{talib.chart.slider.size <[numeric]>}{0.05 by default. Controls the size of the `rangeslider`.}
#'  \item{talib.chart.legend <[logical]>}{`TRUE` by default. If `FALSE` the chart comes without legends.}
#'  \item{talib.chart.scale <[numeric]>}{1 by default. Controls the scale of fonts.}
#' }
#'
#' @param x An OHLC object to be charted.
#' @param type A [character] of [length] 1. Either `candlestick` or `ohlc`.
#' @param idx A [vector] with the same [length] of `x`. If passed it will replace the x-axis labels. See `vignette("charting")` for more details.
#' @param title An optional [character] vector of [length] 1.
#' @param ... Parameters passed into [plotly::plot_ly]
#'
#' @example man/examples/charting.R
#'
#' @author Serkan Korkmaz
chart <- function(
	x,
	type = "candlestick",
	idx = NULL,
	title,
	...
) {
	## clear env if called
	## without passing 'x'
	if (missing(x)) {
		rm(
			list = ls(envir = .plotting_environment, all.names = TRUE),
			envir = .plotting_environment
		)

		return(invisible(NULL))
	}

	UseMethod(
		"chart"
	)
}

#' @export
chart.default <- function(
	x,
	type = "candlestick",
	idx = NULL,
	title,
	...
) {
	## default chart function
	##
	## The chart function works as an initializer
	## for the downstream indicator function calls
	##
	## There are three chart lists:
	##    1. main: The candlestick/bar chart. This is where all
	##             all indicators that are charted on the candlestick
	##             lives alongside the pricechart itself.
	##    2. sub:  A list of indicators. This is where all indicators
	##             that are charted below the main chart lives. For example
	##             RSI, MACD etc.
	##    3. chart: The user-facing TA chart.
	##              This is empty and is constructed on the fly
	##              via plotly::subplot.

	## extract title
	if (missing(title)) {
		chart_title <- input_name(
			substitute(x)
		)
	} else {
		chart_title <- title
	}
	.color_values <- .chart_theme()
	.plotting_environment$sub <- .plotting_environment$chart <- list()

	## convert input to data.frame object
	## and store in the .plotting_environment
	## to avoid having to pass OHLC on every call
	##
	## NOTE: it is also a hard requirement on
	##       {plotly} side
	x <- as.data.frame(x)
	x$idx <- if (is.null(idx)) {
		## check if rownames can be
		## converted to integer
		is_valid <- suppressWarnings(
			!is.na(as.integer(rownames(x)[1]))
		)
		if (is_valid) {
			as.integer(
				rownames(x)
			)
		} else {
			rownames(x)
		}
	} else {
		idx
	}
	.plotting_environment$x <- data_frame <- x
	.plotting_environment$idx <- list(
		label = x$idx,
		index = seq_along(x$idx)
	)

	## generate price chart
	## based on type. can be either
	## candlestick or barchart.
	##
	## TODO: Consider adding the option to use price series
	##       instead of OHLC.
	assert(is.character(type) && length(type) == 1)
	assert(type %in% c("candlestick", "ohlc"))

	price_chart <- plotly::plot_ly(
		data = data_frame,
		type = type,
		x = ~idx,
		open = ~open,
		close = ~close,
		high = ~high,
		low = ~low,

		## colors of bullish
		## and bearish candles/bars
		##
		## NOTE: if fillcolor is NULL
		##       the candles are hollow.
		##       If there is eventual demand this can be changed
		increasing = list(
			line = list(
				color = .color_values$bull_color,
				width = 3 - 1.75
			),
			fillcolor = plotly::toRGB(
				x = .color_values$bull_color,
				alpha = 1 ## This should be controlled from .chart_theme()
			)
		),
		decreasing = list(
			line = list(
				color = .color_values$bear_color,
				width = 3 - 1.75
			),

			fillcolor = plotly::toRGB(
				x = .color_values$bear_color,
				alpha = 1 ## This should be controlled from .chart_theme()
			)
		),

		## remove legend
		## there is no reason to display
		## it in the legend.
		##
		## If there is demand for it we can
		## implement a heuristic to determine intervals
		## for 1h, 2h, etc. Similar to {cryptoQuotes}
		showlegend = FALSE,
		...
	)

	## construct chart meta data
	##
	## There is no relevant information in the range 1:N
	## so if the rownames only contrains integers the chart will
	## skip it
	if (is.integer(.plotting_environment$idx$label)) {
		title_text <- sprintf(
			fmt = "<b>Ticker:</b> %s <br><sub><b>N:</b> %d </sub>",
			chart_title,
			nrow(x)
		)
	} else {
		title_text <- sprintf(
			fmt = "<b>Ticker:</b> %s <br><sub><b>N:</b> %d <b>Period:</b> %s </sub>",
			chart_title,
			nrow(x),
			paste(
				.plotting_environment$idx$label[1],
				"-",
				.plotting_environment$idx$label[length(
					.plotting_environment$idx$label
				)]
			)
		)
	}

	## store in main chart
	## (see description)
	.plotting_environment$main <- .chart_layout(
		x = price_chart,
		title_text = title_text,
		idx = idx
	)

	.plotting_environment$main
}
