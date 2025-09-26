#' @export
#' @family Charting
#' @author Serkan Korkmaz
#'
#' @title Indicator
#'
#' @description
#' This function is a high-level wrapper of the indicator functions and [\{plotly\}](plotly)-objects.
#' Its implemented similar to the [apply]-family, where the indicator function is passed, and its additional arguments
#' are specificied by ...
#'
#' Internally it will look for a [chart]-object, and attach the indicator to the object if found. Otherwise it will return
#' the indicator as a plot if `data` is provided.
#'
#' @param FUN An indicator function
#' @param ... Arguments passed into FUN.
#'
#' @example man/examples/charting.R
#'
#' @author Serkan Korkmaz
indicator <- function(FUN, ...) {
	## plotting environment
	## does exist
	chart_called <- TRUE

	## extract the function
	## directly
	FUN <- match.fun(FUN)

	## locate the main chart
	## NOTE: if its not there we might need
	##       to initialize a new
	plt <- .plotting_environment$main

	if (is.null(plt)) {
		chart_called <- FALSE

		## add empty {plotly}
		## object to trigger .plotly
		## method downstream
		plt <- plotly::plot_ly()
	}

	## construct {plotly}-object
	## based on FUN
	outcome <- do.call(
		what = FUN,
		args = list(
			x = plt,
			...
		)
	)

	## if it doesn't return
	## a {plotly}-object there is
	## a bug somewhere
	if (!inherits(outcome, "plotly")) {
		stop("Unexpected error.")
	}

	if (chart_called) {
		panels <- c(list(.plotting_environment$main), .plotting_environment$sub)
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
			showlegend = TRUE
		)
		.plotting_environment$chart <- fig

		return(fig)
	}

	## reconstruct charting
	## as if called from chart()
	.chart_layout(
		x = outcome,
		title_text = "title_text"
	)
}
