#' @export
#' @family Charting
#' @author Serkan Korkmaz
#'
#' @title Add Technical Indicators to a Chart
#'
#' @description
#' `indicator()` attaches one or more technical indicators to an existing
#' [chart()], or renders an indicator as a standalone chart. Each indicator
#' is displayed in its own subchart panel below the main price chart.
#'
#' If [chart()] has not been called beforehand, `indicator()` creates a
#' standalone indicator chart — in this case, `data` must be provided
#' explicitly.
#'
#' See `vignette(topic = "charting", package = "talib")` for a comprehensive
#' guide.
#'
#' @details
#' `indicator()` operates in two modes depending on how `FUN` is passed:
#'
#' ## Single Indicator Mode
#'
#' Pass a bare function name (without parentheses) and its arguments via
#' `...`:
#'
#' ```r
#' chart(BTC)
#' indicator(RSI, n = 14)
#' ```
#'
#' ## Multi-Indicator Mode
#'
#' Pass one or more indicator calls (with parentheses) to merge them onto
#' a single subchart panel:
#'
#' ```r
#' chart(BTC)
#' indicator(RSI(n = 10), RSI(n = 14), RSI(n = 21))
#' ```
#'
#' Each indicator retains its own arguments. Different indicator types can
#' be freely combined on the same panel:
#'
#' ```r
#' indicator(RSI(n = 14), MACD())
#' ```
#'
#' Multi-indicator mode requires an existing [chart()] — it cannot be used
#' standalone.
#'
#' ## Standalone Mode
#'
#' When no [chart()] has been called, a standalone indicator chart is created.
#' The `data` argument is required in this case:
#'
#' ```r
#' indicator(RSI, data = BTC, n = 14)
#' ```
#'
#' The chart title is automatically derived from the indicator function name,
#' converting `snake_case` to Title Case.
#'
#' ## Panel Layout
#'
#' When subcharts are present, the main price panel occupies 70% of the total
#' height by default (configurable via `options(talib.chart.main = ...)`), and
#' the remaining space is divided equally among subchart panels.
#'
#' @param FUN An indicator function or an indicator call. In single indicator
#'   mode, pass the bare function (e.g., `RSI`); arguments for the indicator
#'   go in `...`. In multi-indicator mode, pass a call with parentheses
#'   (e.g., `RSI(n = 14)`); additional indicator calls go in `...`.
#' @param ... In single indicator mode: arguments passed to `FUN` (e.g.,
#'   `n = 14`, `data = BTC`). In multi-indicator mode: additional indicator
#'   calls to merge onto the same panel (e.g., `RSI(n = 21)`, `MACD()`).
#'
#' @returns
#' A chart object whose class depends on the active backend:
#' \itemize{
#'   \item \code{"plotly"} backend: a \code{plotly} object containing the
#'     assembled multi-panel chart.
#'   \item \code{"ggplot2"} backend: a \code{talib_chart} object (when
#'     combined with [chart()]) or a \code{gg} object (standalone).
#' }
#'
#' @seealso [chart()] to create the main price chart, [set_theme()] to
#'   customize chart colors.
#'
#' @example man/examples/indicator.R
#'
#' @author Serkan Korkmaz
#' @export
indicator <- function(FUN, ...) {
	## detect multi-indicator mode:
	## indicator(RSI(n = 10), MACD()) passes calls
	## indicator(RSI, n = 14) passes a bare function
	fun_expr <- substitute(FUN)

	is_ns_call <- is.call(fun_expr) &&
		(identical(fun_expr[[1]], quote(`::`)) ||
			identical(fun_expr[[1]], quote(`:::`)))

	if (is.call(fun_expr) && !is_ns_call) {
		mc <- match.call(expand.dots = FALSE)
		exprs <- c(list(fun_expr), mc$`...`)
		return(indicator_multi(exprs, parent.frame()))
	}

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
			ggplot2 = {
				assert_ggplot2()
				ggplot2::ggplot()
			},
			stop(
				"Unknown chart backend: '",
				backend,
				"'. ",
				"Supported backends: 'plotly', 'ggplot2'.",
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

		if (inherits(.chart_environment$main, "gg")) {
			return(
				assemble_ggplot2()
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

	if (inherits(outcome, "gg")) {
		return(
			outcome +
				ggplot2::ggtitle(title) +
				ggplot_chart_theme()
		)
	}

	outcome
}

## multi-indicator mode: evaluate each indicator
## call on the same subchart panel, then merge
indicator_multi <- function(exprs, envir) {
	## require an existing chart
	plt <- .chart_environment$main
	if (is.null(plt)) {
		stop(
			"chart() must be called before using indicator() ",
			"with multiple indicators.",
			call. = FALSE
		)
	}

	## record current subchart count
	n_before <- length(.chart_environment$sub)

	## evaluate each indicator expression
	## with x = <chart> injected as first argument
	for (expr in exprs) {
		## resolve the indicator function
		fn <- eval(expr[[1]], envir = envir)

		## build argument list: inject chart object,
		## then evaluate any user arguments that are
		## expressions (e.g. variables, arithmetic)
		user_args <- as.list(expr[-1])
		if (length(user_args) > 0L) {
			user_args <- lapply(user_args, function(a) {
				if (is.language(a)) eval(a, envir = envir) else a
			})
		}
		args <- c(list(x = plt), user_args)

		do.call(fn, args)
	}

	n_after <- length(.chart_environment$sub)
	n_new <- n_after - n_before

	## merge if multiple subchart panels were added
	if (n_new > 1L) {
		if (inherits(plt, "plotly")) {
			merge_subchart_plotly(n_before + 1L, n_after)
		} else if (inherits(plt, "gg")) {
			merge_subchart_ggplot(n_before + 1L, n_after)
		}
	}

	## assemble the final chart
	if (inherits(plt, "plotly")) {
		return(assemble_plotly())
	}
	if (inherits(plt, "gg")) {
		return(assemble_ggplot2())
	}

	stop(
		"Chart assembly not implemented for this backend.",
		call. = FALSE
	)
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
