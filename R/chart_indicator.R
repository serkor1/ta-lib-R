#' @export
#' @family Charting
#' @author Serkan Korkmaz
#'
#' @title Indicator
#'
#' @param FUN An indicator function
#' @param cols A formula of variables.
#' @param ... Arguments passed into [model.frame]
#'
#' @description
#' Add an indicator to t
#'
indicator <- function(FUN, ...) {
	## extract the function
	## directly
	FUN <- match.fun(FUN)

	## locate the main chart
	## NOTE: if its not there we might need
	##       to initialize a new
	plt <- .plotting_environment$main

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

	panels <- c(list(.plotting_environment$main), .plotting_environment$sub)
	stopifnot(all(vapply(panels, inherits, logical(1), what = "plotly")))
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
