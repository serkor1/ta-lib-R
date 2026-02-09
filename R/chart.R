#' @export
#' @family Charting
#' @author Serkan Korkmaz
#'
#' @title OHLC Chart
#'
#' @description
#' `chart()` is a generic S3 function for charting OHLC-V series interactively.
#' The function is a high-level [plotly::plot_ly] wrapper with pre-specified OHLC values based on the input data.
#'
#' Call `chart()` without any arguments to reset the charting
#' environment. See `vignette(topic = "charting", package = "talib")` for more details.
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
#' @param x An OHLC-V object coercible to [data.frame].
#' @param type A [character] of [length] 1. `candlestick` by default. Can be `ohlc` for OHLC bars.
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

	candle_style <- function(
		bull_candle,
		bear_candle,
		line_width,
		alpha = 1
	) {
		side <- function(col) {
			list(
				line = list(
					color = col,
					width = line_width
				),
				fillcolor = plotly::toRGB(
					col,
					alpha = alpha
				)
			)
		}

		list(
			increasing = side(bull_candle),
			decreasing = side(bear_candle)
		)
	}

	base <- plotly::plot_ly(
		data = data_frame,
		x = ~idx,
		open = ~open,
		close = ~close,
		high = ~high,
		low = ~low,
		showlegend = FALSE,
		...
	)

	border_chart <- do.call(
		plotly::add_trace,
		c(
			list(p = base, type = type),
			candle_style(
				.chart_variables$bullish_border,
				.chart_variables$bearish_border,
				line_width = 2
			)
		)
	)

	price_chart <- do.call(
		plotly::add_trace,
		c(
			list(
				p = border_chart,
				type = type
			),
			candle_style(
				.chart_variables$bullish_body,
				.chart_variables$bearish_body,
				line_width = 1
			)
		)
	)

	## construct chart meta data
	##
	## There is no relevant information in the range 1:N
	## so if the rownames only contrains integers the chart will
	## skip it
	if (is.integer(.plotting_environment$idx$label)) {
		title_text <- sprintf(
			fmt = "%s <span style='font-size:10;'><b>N:</b> %d </span>",
			chart_title,
			nrow(x)
		)
	} else {
		title_text <- sprintf(
			fmt = "%s <span style='font-size:10;'><b>N:</b> %d <b>Period:</b> %s</span>",
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

	## construct price chart
	##
	##
	fns <- list(
		function(p) layout_background(p),
		function(p) layout_axis(p, idx = idx),
		function(p) {
			layout_title(
				p,
				title = title_text
			)
		},
		function(p) layout_font(p),
		function(p) layout_legend(p),
		function(p) {
			add_last_value(
				p,
				data = data_frame,
				remove_cols = "volume"
			)
		},
		function(p) layout_color(p)
	)

	.plotting_environment$main <- Reduce(
		f = function(p, f) f(p),
		x = fns,
		init = price_chart
	)

	layout_settings(
		.plotting_environment$main
	)
}
