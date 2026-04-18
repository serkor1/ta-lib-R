#' @export
#' @family Charting
#' @author Serkan Korkmaz
#'
#' @title Create an OHLC Chart
#'
#' @description
#' `chart()` creates interactive candlestick or OHLC bar charts from financial
#' price data. It initializes the charting environment so that subsequent calls
#' to [indicator()] can attach technical indicators as subcharts.
#'
#' Calling `chart()` without any arguments resets the charting environment,
#' clearing all stored chart state (main chart, subcharts, and data).
#'
#' See `vignette(topic = "charting", package = "talib")` for a comprehensive
#' guide on building multi-panel technical analysis charts.
#'
#' @details
#' `chart()` acts as the entry point for the package's charting system. It
#' stores the OHLC data and the main price chart internally so that subsequent
#' [indicator()] calls can attach panels below the price chart without
#' requiring the data to be passed again.
#'
#' The chart title is automatically inferred from the name of the object passed
#' to `x` (e.g., `chart(BTC)` produces the title "BTC"). The title also
#' displays the number of observations and, when available, the date range.
#'
#' Two rendering backends are supported:
#' \describe{
#'   \item{`"plotly"` (default)}{Produces interactive HTML charts with hover
#'     tooltips, pan/zoom, and built-in drawing tools (lines, rectangles).
#'     Requires the \pkg{plotly} package.}
#'   \item{`"ggplot2"`}{Produces static charts suitable for reports and
#'     publications. Requires the \pkg{ggplot2} package.}
#' }
#'
#' ## Options
#'
#' The following [options()] control chart appearance and behavior:
#'
#' \describe{
#'  \item{`talib.chart.backend` \[character\]}{`"plotly"` by default. Set to
#'    `"ggplot2"` for static charts.}
#'  \item{`talib.chart.slider` \[logical\]}{`FALSE` by default. If `TRUE`, a
#'    range slider is added below the x-axis for interactive zooming (plotly
#'    backend only).}
#'  \item{`talib.chart.slider.size` \[numeric\]}{`0.05` by default. Controls
#'    the height of the range slider as a fraction of the total chart height.}
#'  \item{`talib.chart.legend` \[logical\]}{`TRUE` by default. If `FALSE`,
#'    legends are hidden on all panels.}
#'  \item{`talib.chart.scale` \[numeric\]}{`1` by default. A scaling factor
#'    applied to all font sizes. Values greater than 1 increase font size.}
#'  \item{`talib.chart.main` \[numeric\]}{`0.7` by default. The fraction of
#'    total chart height allocated to the main price panel when subcharts
#'    are present.}
#' }
#'
#' Colors are controlled via [set_theme()]. See [set_theme()] for available
#' themes and color customization.
#'
#' ## State and concurrency
#'
#' The `chart()` + [indicator()] pair follows the same active-target
#' model as base R's [plot()] / [lines()]. When `chart()` is called it
#' stashes a per-pipeline state object in its caller's evaluation frame;
#' subsequent [indicator()] calls retrieve the state by walking up the
#' call stack.
#'
#' The practical consequences:
#'
#' - `chart()` and the subsequent [indicator()] calls must live in the
#'   **same enclosing frame** - the same REPL session, the same function
#'   body, the same `renderPlot()` / `renderPlotly()` block, the same
#'   `local({...})` expression, the same `testthat::test_that({...})`
#'   block, etc. Splitting them across unrelated helpers is not
#'   supported.
#' - Two unrelated function bodies (or two parallel `renderPlot()`
#'   callbacks in a Shiny app, or two `future::future()` blocks) each
#'   get their own frame, so their chart states are isolated by
#'   construction - without `talib` taking any dependency on Shiny,
#'   promises, or futures.
#' - Calling `chart()` with no arguments clears the state in the
#'   caller's frame, mirroring a fresh `plot()` call on a new device.
#'
#' @param x An OHLC-V [data.frame] (or object coercible to one) with columns
#'   named `open`, `high`, `low`, `close`, and optionally `volume`. Column
#'   names are case-sensitive.
#' @param type A [character] string, either `"candlestick"` (default) or
#'   `"ohlc"`. Candlestick charts use filled/hollow bodies with wicks; OHLC
#'   charts use vertical bars with horizontal open/close ticks.
#' @param idx An optional [vector] with the same [length] as the number of
#'   rows in `x`. Replaces the default x-axis labels (row names or integer
#'   index). Useful for custom date formatting or non-standard index types.
#' @param title An optional [character] string for the chart title. If
#'   omitted, the title is inferred from the variable name passed to `x`.
#' @param ... Additional parameters passed to the backend chart constructor
#'   (e.g., [plotly::plot_ly()]).
#'
#' @returns
#' A chart object whose class depends on the active backend:
#' \itemize{
#'   \item \code{"plotly"} backend: a \code{plotly} object (interactive HTML
#'     widget).
#'   \item \code{"ggplot2"} backend: a \code{gg} object (static plot).
#' }
#'
#' When called without arguments, returns `NULL` invisibly.
#'
#' @seealso [indicator()] to attach technical indicators, [set_theme()] to
#'   customize chart colors.
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
	## clear state if called
	## without passing 'x'
	if (missing(x)) {
		.chart_state_reset(envir = parent.frame())
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
	## The chart function works as an initializer
	## for the downstream indicator function calls.
	##
	## There are three chart lists:
	##    1. main: The candlestick/bar chart. This is where all
	##             indicators that are charted on the candlestick
	##             live alongside the price chart itself.
	##    2. sub:  A list of indicators charted below the main chart.
	##             For example RSI, MACD etc.
	##    3. chart: The user-facing TA chart.
	##              This is empty and is constructed on the fly.

	## extract title
	if (missing(title)) {
		chart_title <- input_name(
			substitute(x)
		)
	} else {
		chart_title <- title
	}

	## create a fresh per-pipeline state env in the user's frame.
	## With UseMethod dispatch, parent.frame() inside chart.default
	## resolves to the user's frame (one level above the generic).
	state <- .chart_state_create(envir = parent.frame())
	state$sub <- list()
	state$chart <- list()

	## convert input to data.frame and store in state
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
	state$x <- x
	state$idx <- list(
		label = x$idx,
		index = seq_along(x$idx)
	)

	## validate chart type
	assert(is.character(type) && length(type) == 1)
	assert(type %in% c("candlestick", "ohlc"))

	## delegate to backend-specific chart builder
	backend <- getOption("talib.chart.backend", "plotly")

	switch(
		backend,
		plotly = {
			assert_plotly_pkg()
			chart_plotly(
				data = x,
				type = type,
				title = chart_title,
				idx = idx,
				...
			)
		},
		ggplot2 = chart_ggplot2(
			data = x,
			type = type,
			title = chart_title,
			idx = idx,
			...
		),
		stop(
			"Unknown chart backend: '",
			backend,
			"'. ",
			"Supported backends: 'plotly', 'ggplot2'.",
			call. = FALSE
		)
	)
}

## ---- plotly backend ----

## build a candlestick or OHLC chart
## using plotly as the rendering backend
chart_plotly <- function(
	data,
	type,
	title,
	idx,
	...
) {
	## helper to construct increasing and
	## decreasing candle style lists
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

	## initialize the plotly object
	## with OHLC data
	base <- plotly::plot_ly(
		data = data,
		x = ~idx,
		open = ~open,
		close = ~close,
		high = ~high,
		low = ~low,
		showlegend = FALSE,
		...
	)

	## add border trace with thick lines
	## for candle outlines
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

	## add body trace with thin lines
	## for candle fill colors
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

	## construct chart title
	state <- .chart_state()
	if (is.integer(state$idx$label)) {
		title_text <- sprintf(
			fmt = "%s <span style='font-size:10;'><b>N:</b> %d </span>",
			title,
			nrow(data)
		)
	} else {
		title_text <- sprintf(
			fmt = "%s <span style='font-size:10;'><b>N:</b> %d <b>Period:</b> %s</span>",
			title,
			nrow(data),
			paste(
				state$idx$label[1],
				"-",
				state$idx$label[length(
					state$idx$label
				)]
			)
		)
	}

	## apply plotly layout decorators
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
			add_last_value_ly(
				p,
				data = data
			)
		},
		function(p) layout_color(p)
	)

	state$main <- Reduce(
		f = function(p, f) f(p),
		x = fns,
		init = price_chart
	)

	layout_settings(
		state$main
	)
}
