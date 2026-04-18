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
	## Routing between SINGLE-indicator and MULTI-indicator modes.
	##
	## SINGLE mode (one indicator, args via ...):
	##   indicator(RSI, n = 14)
	##   indicator(talib::RSI, n = 14)
	##   indicator(get("RSI"), n = 14)         # indirect lookup
	##   indicator(match.fun(RSI), n = 14)     # also indirect
	##   indicator(my_fn_holding_RSI, n = 14)  # bound variable
	##
	## MULTI mode (merge several indicator panels - each call is re-
	## evaluated with x = <chart> injected by indicator_multi):
	##   indicator(RSI(n = 10), RSI(n = 14), RSI(n = 21))
	##   indicator(RSI(n = 14), MACD())
	##
	## The disambiguation rule is:
	##   - a bare name (`RSI`) or a namespace expression (`talib::RSI`)
	##     never routes to MULTI (these are cheap to evaluate and
	##     always denote the indicator function itself)
	##   - every other call expression is evaluated once in the caller's
	##     frame; if it resolves to a function the call must be an
	##     indirect reference (`get()`, `match.fun()`, ...) and we take
	##     SINGLE mode; otherwise we fall back to MULTI, which will
	##     re-evaluate the call with x = <chart> injected.
	##
	## Previously this code assumed every call-shaped FUN was an
	## indicator call, which broke `indicator(get("RSI"), n = 14)` and
	## similar indirect-lookup forms.
	fun_expr <- substitute(FUN)

	is_simple_ref <- is.name(fun_expr) ||
		(is.call(fun_expr) &&
			(identical(fun_expr[[1L]], quote(`::`)) ||
				identical(fun_expr[[1L]], quote(`:::`))))

	if (!is_simple_ref && is.call(fun_expr)) {
		## A call that isn't a bare name or namespace expression - could
		## be an indicator call (multi mode) or an indirect function
		## reference (single mode). Try evaluating it; if we get back a
		## function, single mode wins.
		resolved <- tryCatch(
			eval(fun_expr, envir = parent.frame()),
			error = function(e) NULL
		)

		if (is.function(resolved)) {
			## Indirect function reference - reuse resolved to skip a
			## second evaluation in the downstream dispatch.
			FUN <- resolved
			return(UseMethod("indicator"))
		}

		## Fall through to MULTI mode. indicator_multi will re-evaluate
		## each expression with x = <chart> injected.
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

	## extract the function
	## directly
	FUN <- match.fun(FUN)

	## locate the active chart state from the caller's frame chain
	state <- .chart_state()
	plt <- if (!is.null(state)) state$main else NULL
	chart_called <- !is.null(plt)

	if (!chart_called) {
		## standalone mode: indicator() called without prior chart()
		if (has_arg(data)) {
			data <- eval.parent(
				match.call()[["data"]]
			)
		} else {
			stop(
				"'data' must be supplied when calling indicator() ",
				"without first calling chart(). ",
				"Example: indicator(RSI, data = BTC).",
				call. = FALSE
			)
		}

		## create an empty chart object
		## for the active backend
		backend <- getOption("talib.chart.backend", "plotly")
		plt <- switch(
			backend,
			plotly = {
				assert_plotly_pkg()
				plotly::plot_ly()
			},
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

		## create transient state in indicator()'s OWN frame so that
		## helpers called from FUN (series(), add_idx(), ...) can find
		## what they need via dynGet. The state evaporates when this
		## function returns - no leakage to the user's frame.
		state <- .chart_state_create(envir = environment())
		state$idx <- list(label = idx)
		state$x <- as.data.frame(data)
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
		stop(
			"indicator() expected FUN to return a 'plotly' or 'gg' object, ",
			"got ",
			paste(class(outcome), collapse = "/"),
			".",
			call. = FALSE
		)
	}

	if (chart_called) {
		## assemble the multi-panel chart
		## based on the backend
		if (inherits(state$main, "plotly")) {
			return(
				assemble_plotly()
			)
		}

		if (inherits(state$main, "gg")) {
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
		return(wrap_gg(
			outcome +
				ggplot2::ggtitle(title) +
				ggplot_chart_theme()
		))
	}

	outcome
}

## multi-indicator mode: evaluate each indicator
## call on the same subchart panel, then merge
indicator_multi <- function(exprs, envir) {
	## require an existing chart
	plt <- .chart_state()$main
	if (is.null(plt)) {
		stop(
			"chart() must be called before using indicator() ",
			"with multiple indicators.",
			call. = FALSE
		)
	}

	## record current subchart count
	n_before <- length(.chart_state()$sub)

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

	n_after <- length(.chart_state()$sub)
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

## ---- internal subchart merge ----

## merge multiple subchart panels into one
## for the plotly backend - used by indicator_multi
## to overlay indicators on a single panel
merge_subchart_plotly <- function(from, to) {
	state <- .chart_state()

	## build the base panel
	base <- plotly::plotly_build(state$sub[[from]])

	## merge traces and annotations
	## from subsequent panels
	for (i in seq(from + 1L, to)) {
		other <- plotly::plotly_build(state$sub[[i]])
		base$x$data <- c(base$x$data, other$x$data)

		## merge annotations like subchart
		## titles and last-value labels
		if (length(other$x$layout$annotations) > 0L) {
			base$x$layout$annotations <- c(
				base$x$layout$annotations,
				other$x$layout$annotations
			)
		}
	}

	## remove explicit y-range so plotly
	## auto-scales for the combined data
	base$x$layout$yaxis$range <- NULL
	base$x$layout$yaxis$autorange <- TRUE

	## reassign colors to legend-bearing traces
	## so merged indicators are visually distinct
	colorway <- .chart_variables$colorway
	color_i <- 0L
	for (j in seq_along(base$x$data)) {
		tr <- base$x$data[[j]]
		if (isTRUE(tr$showlegend)) {
			color_i <- color_i + 1L
			color <- colorway[((color_i - 1L) %% length(colorway)) + 1L]
			base$x$data[[j]]$line$color <- color
		}
	}

	## replace first panel with merged
	## and drop the rest
	state$sub[[from]] <- base
	length(state$sub) <- from
}

## merge multiple subchart panels into one
## for the ggplot2 backend - used by indicator_multi
## to overlay indicators on a single panel
merge_subchart_ggplot <- function(from, to) {
	state <- .chart_state()
	base <- state$sub[[from]]

	## collect layers from subsequent panels
	for (i in seq(from + 1L, to)) {
		other <- state$sub[[i]]
		for (layer in other$layers) {
			base <- base + layer
		}
	}

	## remove coord constraints so the merged
	## panel auto-scales for combined data
	suppressMessages(
		base <- base + ggplot2::coord_cartesian()
	)

	## rebuild color scale for all legend entries
	## so each indicator gets a distinct color
	colorway <- .chart_variables$colorway
	legend_names <- character(0)
	for (layer in base$layers) {
		if (!is.null(layer$data) && ".legend" %in% names(layer$data)) {
			legend_names <- c(
				legend_names,
				unique(layer$data[[".legend"]])
			)
		}
	}
	legend_names <- unique(legend_names)

	if (length(legend_names) > 0L) {
		color_map <- .set_names(
			colorway[seq_along(legend_names)],
			legend_names
		)

		## remove existing colour scale
		base$scales$scales <- Filter(
			function(s) !("colour" %in% s$aesthetics),
			base$scales$scales
		)
		base <- base +
			ggplot2::scale_colour_manual(
				name = NULL,
				values = color_map,
				breaks = legend_names
			)
	}

	## build combined last-value subtitle
	## from all merged panels using spec names
	## opt-out via options(talib.chart.merged_last_value = FALSE)
	if (getOption("talib.chart.merged_last_value", TRUE)) {
		last_values <- list()
		for (i in seq(from, to)) {
			lv <- attr(state$sub[[i]], "talib_last_value")
			if (!is.null(lv)) {
				last_values <- c(last_values, list(lv))
			}
		}

		if (length(last_values) > 0L) {
			## build subtitle parts using spec names
			## single output: RSI(10): 45.32
			## multi output: MACD(12,26,9): 0.50 / 0.30 / 0.20
			parts <- lapply(last_values, function(lv) {
				label <- lv$name
				if (length(lv$values) == 1L) {
					val_str <- sprintf("%.2f", lv$values[[1L]])
				} else {
					val_str <- paste(
						sprintf("%.2f", lv$values),
						collapse = " / "
					)
				}
				bquote(
					bold(.(paste0(label, ":"))) ~ .(val_str)
				)
			})

			value_expr <- as.expression(
				if (length(parts) == 1L) {
					parts[[1L]]
				} else {
					Reduce(
						function(a, b) bquote(.(a) ~ ~ .(b)),
						parts
					)
				}
			)

			base <- base +
				ggplot2::labs(subtitle = value_expr) +
				ggplot2::theme(
					plot.subtitle = ggplot2::element_text(
						hjust = 1,
						size = 10 *
							(72 / 96) *
							getOption("talib.chart.scale", 1),
						color = .chart_variables$text_color
					)
				)
		}
	} else {
		base$labels$subtitle <- NULL
	}

	## replace first panel with merged
	## and drop the rest
	state$sub[[from]] <- base
	length(state$sub) <- from
}

## ---- plotly assembly ----

## combine main chart and subcharts
## into a multi-panel plotly subplot
assemble_plotly <- function() {
	state <- .chart_state()
	panels <- c(list(state$main), state$sub)
	n <- length(panels)

	## main panel gets most of the height
	## subcharts split the remainder equally
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
	state$chart <- fig

	layout_axis(layout_color(layout_settings(fig)))
}

## ---- ggplot2 assembly ----

## combine main chart and subcharts
## into a multi-panel ggplot2 layout
assemble_ggplot2 <- function() {
	state <- .chart_state()
	panels <- c(
		list(state$main),
		state$sub
	)
	n <- length(panels)

	## single panel - return as-is (wrapped for safe auto-printing)
	if (n == 1L) {
		state$chart <- panels[[1]]
		return(wrap_gg(panels[[1]]))
	}

	## main panel gets most of the height
	## subcharts split the remainder equally
	main_h <- getOption("talib.chart.main", 0.7)
	heights <- c(
		main_h,
		rep(
			(1 - main_h) / (n - 1),
			n - 1
		)
	)

	## remove x-axis elements from all
	## panels except the bottom one
	for (i in seq_len(n - 1)) {
		panels[[i]] <- panels[[i]] +
			ggplot2::theme(
				axis.text.x = ggplot2::element_blank(),
				axis.ticks.x = ggplot2::element_blank(),
				plot.margin = ggplot2::margin(2, 5, 0, 5)
			)
	}

	## convert to grobs and align column widths
	## so that y-axes line up across panels
	## use a null device to prevent Rplots.pdf
	grDevices::pdf(nullfile())
	dev_null <- grDevices::dev.cur()
	on.exit(grDevices::dev.off(dev_null), add = TRUE)
	grobs <- lapply(panels, ggplot2::ggplotGrob)
	max_widths <- do.call(
		grid::unit.pmax,
		lapply(grobs, function(g) g$widths)
	)
	grobs <- lapply(grobs, function(g) {
		g$widths <- max_widths
		g
	})

	## assemble into a talib_chart object
	fig <- structure(
		list(
			grobs = grobs,
			heights = heights,
			n = n
		),
		class = "talib_chart"
	)

	state$chart <- fig
	fig
}

## Wrap a ggplot2 return with a class whose print method opens a null
## device when none is active. Prevents Rplots.pdf from appearing in
## non-interactive contexts (R CMD check, Rscript) while leaving
## interactive use untouched - in the REPL dev.cur() is not 1, so the
## null-device branch is skipped and the user's device is used as-is.
wrap_gg <- function(x) {
	if (inherits(x, "gg") && !inherits(x, "talib_gg_chart")) {
		class(x) <- c("talib_gg_chart", class(x))
	}
	x
}

## print method for single-panel ggplot charts returned by chart() /
## indicator() on the ggplot2 backend. Guards against Rplots.pdf
## creation in non-interactive contexts and delegates rendering to
## ggplot2 via NextMethod.
#' @export
print.talib_gg_chart <- function(x, ...) {
	if (grDevices::dev.cur() == 1L) {
		grDevices::pdf(nullfile())
		on.exit(grDevices::dev.off(), add = TRUE)
	}
	NextMethod()
}

## print method for multi-panel ggplot2 charts
## uses grid viewports for proportional panel heights
#' @export
print.talib_chart <- function(x, ...) {
	## avoid Rplots.pdf when no device is open
	## (e.g., R CMD check, tests, vignette knit)
	if (grDevices::dev.cur() == 1L) {
		grDevices::pdf(nullfile())
		on.exit(grDevices::dev.off(), add = TRUE)
	}

	grid::grid.newpage()

	layout <- grid::grid.layout(
		nrow = x$n,
		ncol = 1,
		heights = grid::unit(x$heights, "null")
	)

	grid::pushViewport(
		grid::viewport(layout = layout)
	)

	for (i in seq_len(x$n)) {
		grid::pushViewport(
			grid::viewport(layout.pos.row = i)
		)
		grid::grid.draw(x$grobs[[i]])
		grid::popViewport()
	}

	grid::popViewport()
	invisible(x)
}
