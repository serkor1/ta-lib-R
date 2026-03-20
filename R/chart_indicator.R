#' @export
#' @family Charting
#' @author Serkan Korkmaz
#'
#' @title Indicator Chart
#'
#' @description
#' `indicator()` will look for an existing [chart()]-object and attach the indicator accordingly. All indicators can be charted indepently of whether [chart()] have been called.
#'
#' If no [chart()] have been called prior to [indicator()] the indicator will be charted by itself if `data` is provided. See `vignette(topic = "charting", package = "talib")` for more details.
#'
#' @param FUN An indicator function.
#' @param ... Arguments passed into FUN.
#'
#' @example man/examples/indicator.R
#'
#' @author Serkan Korkmaz
#' @export
indicator <- function(FUN, ...) {
	UseMethod("indicator")
}

#' @export
indicator.function <- function(FUN, ...) {
	## resolve function name if no
	## title has been passed
	title <- input_name(
		substitute(
			FUN
		)
	)

	## clean up title
	if (any(grepl(x = title, pattern = "_"))) {
		title <- to_title(
			title
		)
	}

	## plotting environment
	## does exist
	chart_called <- TRUE

	## extract the function
	## directly
	FUN <- match.fun(FUN)

	## locate the main chart
	plt <- .chart_environment$main

	if (is.null(plt)) {
		chart_called <- FALSE

		if (has_arg(data)) {
			data <- eval.parent(
				match.call()[["data"]]
			)
		} else {
			stop("'data'-argument has to be provided.")
		}

		## create an empty chart object
		## for the active backend
		backend <- getOption("talib.chart.backend", "plotly")
		plt <- switch(
			backend,
			plotly = plotly::plot_ly(),
			stop(
				"Unknown chart backend: '",
				backend,
				"'. ",
				"Supported backends: 'plotly'.",
				call. = FALSE
			)
		)

		if (has_arg(idx)) {
			idx <- eval.parent(
				match.call()[["idx"]]
			)
		} else {
			idx <- rownames(
				data
			)
		}

		.chart_environment$idx$label <- idx
	}

	## dispatch to the appropriate backend method
	## based on the class of 'plt'
	outcome <- do.call(
		what = FUN,
		args = list(
			x = plt,
			...
		)
	)

	## verify return type
	if (!inherits(outcome, c("plotly", "gg"))) {
		stop("Unexpected error.")
	}

	if (chart_called) {
		## assemble the multi-panel chart
		## based on the backend
		if (inherits(.chart_environment$main, "plotly")) {
			return(
				assemble_plotly()
			)
		}

		stop(
			"Chart assembly not implemented for this backend.",
			call. = FALSE
		)
	}

	## reconstruct charting
	## as if called from chart()
	if (inherits(outcome, "plotly")) {
		fns <- list(
			function(p) layout_background(p),
			function(p) layout_axis(p, idx = idx),
			function(p) {
				layout_title(
					p,
					title = title
				)
			},
			function(p) layout_font(p),
			function(p) layout_color(p)
		)

		return(
			Reduce(
				f = function(p, f) f(p),
				x = fns,
				init = outcome
			)
		)
	}

	outcome
}

## plotly subplot assembly
assemble_plotly <- function() {
	panels <- c(list(.chart_environment$main), .chart_environment$sub)
	n <- length(panels)
	main_h <- getOption("talib.chart.main", 0.7)
	heights <- if (n > 1) {
		c(main_h, rep((1 - main_h) / (n - 1), n - 1))
	} else {
		1
	}
	fig <- plotly::layout(
		plotly::subplot(
			panels,
			nrows = n,
			shareX = TRUE,
			margin = 0.02,
			heights = heights
		),
		showlegend = TRUE,
		yaxis = list(title = ''),
		xaxis = list(
			title = '',
			tickmode = "auto"
		)
	)
	.chart_environment$chart <- fig

	layout_axis(layout_color(layout_settings(fig)))
}
