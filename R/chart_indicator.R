#' @title Chart indicators
#' @export
indicator <- function(
	FUN,
	cols,
	...
) {
	## indicator
	##
	## description:
	## the indicator function builds upon existing
	## {plotly} objects if it has been defined, otherwise
	## it will create a standalone chart with the indicator
	## only
	parent_frame <- parent.frame()

	## resolve passed formula
	## via 'cols' and store in the
	## parent_frame
	has_var <- !missing(cols)
	if (has_var) {
		var_expr <- eval.parent(substitute(cols))
		stopifnot(inherits(var_expr, "formula"))
		environment(var_expr) <- parent_frame
	}

	## resolve the call
	## passed via FUN
	f_call <- substitute(FUN)
	pre_args <- list()
	if (is.call(f_call)) {
		f <- eval(f_call[[1L]], envir = parent_frame)
		pre_args <- as.list(f_call)[-1L]
	} else {
		f <- match.fun(eval.parent(f_call))
	}

	## resolve plotting
	## environment; if it exists
	## it means talib::chart has been called
	## otherwise generate a new environment and
	## work off of that
	.plotting_environment <- get0(
		".plotting_environment",
		inherits = TRUE
	)
	if (is.null(.plotting_environment)) {
		.plotting_environment <- new.env(parent = emptyenv())
		assign(
			".plotting_environment",
			.plotting_environment,
			inherits = TRUE
		)
	}

	if (is.null(.plotting_environment$main)) {
		.plotting_environment$main <- .chart_layout(
			x = plotly::plotly_empty(),
			title_text = "fisk"
		)
	}

	.plot <- .plotting_environment$main

	## build the FUN call
	## with argument and let the
	## the dispatcher handle the rest
	dots <- as.list(substitute(list(...)))[-1L]
	args <- c(list(x = .plot), pre_args)

	if (has_var) {
		f_formals <- tryCatch(
			names(formals(f)),
			error = function(e) {
				character()
			}
		)
		name <- intersect(c("cols", "formula"), f_formals)[1]
		if (!is.na(name)) args[[name]] <- var_expr
	}

	output <- do.call(f, c(args, dots), envir = parent_frame, quote = TRUE)

	## construct plotly object
	## if based off of the char
	if (inherits(output, "plotly")) {
		panels <- c(
			list(.plotting_environment$main),
			.plotting_environment$sub
		)
		stopifnot(all(vapply(
			panels,
			inherits,
			logical(1),
			what = "plotly"
		)))
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

			## this part is necessary
			## to avoid local subplots
			## to interfere with the main
			## plot
			showlegend = TRUE
		)
		.plotting_environment$chart <- fig
		return(fig)
	}

	output
}
