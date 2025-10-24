#' @export
#' @family Cycle Indicator
#'
#' @title Hilbert Transform - Trend vs Cycle Mode
#' @templateVar .title Hilbert Transform - Trend vs Cycle Mode
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun trend_cycle_mode
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
trend_cycle_mode <- function(
	x,
	cols,
	...
) {
	UseMethod("trend_cycle_mode")
}

#' @export
#' @usage NULL
#' @rdname trend_cycle_mode
#'
#' @aliases trend_cycle_mode
HT_TRENDMODE <- trend_cycle_mode

#' @usage NULL
#' @aliases trend_cycle_mode
#'
#' @export
trend_cycle_mode.default <- function(
	x,
	cols,
	...
) {
	## validate 'cols'-argument
	## if explicitly passed
	if (!missing(cols)) {
		assert_formula(cols)
	}

	## construct series
	## from input
	constructed_series <- series(
		x = cols,
		default = ~close,
		data = x,
		...
	)

	## extract rownames
	## for later attachment
	x_names <- rownames(x)

	## calculate indicator and
	## return as data.frame
	x <- .Call(
		"impl_ta_HT_TRENDMODE",
		## splice:call:start
		constructed_series[[1]]
		## splice:call:end
	)

	## readd rownames
	rownames(x) <- x_names

	## return indicator
	x
}

#' @usage NULL
#' @aliases trend_cycle_mode
#'
#' @export
trend_cycle_mode.data.frame <- function(
	x,
	cols,
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases trend_cycle_mode
#'
#' @export
trend_cycle_mode.matrix <- function(
	x,
	cols,
	...
) {
	as.matrix(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases trend_cycle_mode
#'
#' @export
trend_cycle_mode.plotly <- function(
	x,
	cols,
	## splice:optional-plotly:start
	## splice:optional-plotly:end
	...
) {
	## check that input value
	## 'x' is <plotly>-object
	assert_plotly(x)

	## check that input value
	## 'cols' is a <formula>-objet
	if (!missing(cols)) {
		assert_formula(cols)
	}

	## construct series from
	## {plotly}-object
	constructed_series <- series(
		x = x,
		formula = cols,
		default = ~close,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- trend_cycle_mode(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		)
	)

	## add conditional idx
	constructed_indicator[["idx"]] <- add_idx(
		constructed_series
	)

	## construct {plotly}-object
	## splice:plotly-assembly:start
	plotly_object <- subchart(
		data = constructed_indicator,
		y = ~TRENDMODE,
		type = "scatter",
		mode = "lines",
		name = "Trendmode",
		line = list(shape = "hvh")
	)

	if (main_chart_exists()) {
		plotly_object <- add_title(
			x = plotly_object,
			text = "Trendmode"
		)
	}

	.plotting_environment$sub <- c(
		.plotting_environment$sub,
		list(plotly_object)
	)
	## splice:plotly-assembly:end

	plotly_object
}
