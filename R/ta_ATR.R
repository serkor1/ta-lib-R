#' @export
#' @family Volatility Indicator
#'
#' @title Average True Range
#' @templateVar .title Average True Range
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun average_true_range
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
#' @template returns
average_true_range <- function(
	x,
	cols,
	n = 10,
	...
) {
	UseMethod("average_true_range")
}

#' @export
#' @usage NULL
#' @rdname average_true_range
#'
#' @aliases average_true_range
ATR <- average_true_range

#' @usage NULL
#' @aliases average_true_range
#'
#' @export
average_true_range.default <- function(
	x,
	cols,
	n = 10,
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
		default = ~ high + low + close,
		data = x,
		...
	)

	## extract rownames
	## for later attachment
	x_names <- rownames(constructed_series)

	## calculate indicator and
	## return as data.frame
	x <- .Call(
		"impl_ta_ATR",
		## splice:call:start
		constructed_series[[1]],
		constructed_series[[2]],
		constructed_series[[3]],
		as.integer(n)
		## splice:call:end
	)

	## readd rownames
	set_rownames(x, x_names)

	## return indicator
	x
}

#' @usage NULL
#' @aliases average_true_range
#'
#' @export
average_true_range.data.frame <- function(
	x,
	cols,
	n = 10,
	...
) {
	as.data.frame(
		average_true_range.default(
			x = x,
			cols = cols,
			n = n,
			...
		)
	)
}

#' @usage NULL
#' @aliases average_true_range
#'
#' @export
average_true_range.matrix <- function(
	x,
	cols,
	n = 10,
	...
) {
	as.matrix(
		average_true_range.default(
			x = x,
			cols = cols,
			n = n,
			...
		)
	)
}

#' @usage NULL
#' @aliases average_true_range
#'
#' @export
average_true_range.plotly <- function(
	x,
	cols,
	n = 10,
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
		default = ~ high + low + close,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- average_true_range(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		n = n
	)

	## add conditional idx
	constructed_indicator[["idx"]] <- add_idx(
		constructed_series
	)

	## construct {plotly}-object
	## splice:plotly-assembly:start
	plotly_object <- subchart(
		data = constructed_indicator,
		y = ~ATR,
		type = "scatter",
		mode = "lines",
		showlegend = FALSE
	)

	if (main_chart_exists()) {
		plotly_object <- add_title(
			x = plotly_object,
			text = "Average True Range"
		)
	}

	.plotting_environment$sub <- c(
		.plotting_environment$sub,
		list(plotly_object)
	)
	## splice:plotly-assembly:end

	plotly_object
}
