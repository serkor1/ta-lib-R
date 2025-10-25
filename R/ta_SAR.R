#' @export
#' @family Overlap Study
#'
#' @title Parabolic Stop and Reverse (SAR)
#' @templateVar .title Parabolic Stop and Reverse (SAR)
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun parabolic_stop_and_reverse
#'
## splice:documentation:start
#' @param acceleration  Acceleration factor used up to the maximum value
#' @param maximum Acceleration factor maximum value
## splice:documentation:end
#'
#' @template description
parabolic_stop_and_reverse <- function(
	x,
	cols,
	acceleration = 0.5,
	maximum = 0.75,
	...
) {
	UseMethod("parabolic_stop_and_reverse")
}

#' @export
#' @usage NULL
#' @rdname parabolic_stop_and_reverse
#'
#' @aliases parabolic_stop_and_reverse
SAR <- parabolic_stop_and_reverse

#' @usage NULL
#' @aliases parabolic_stop_and_reverse
#'
#' @export
parabolic_stop_and_reverse.default <- function(
	x,
	cols,
	acceleration = 0.5,
	maximum = 0.75,
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
		default = ~ high + low,
		data = x,
		...
	)

	## extract rownames
	## for later attachment
	x_names <- rownames(constructed_series)

	## calculate indicator and
	## return as data.frame
	x <- .Call(
		"impl_ta_SAR",
		## splice:call:start
		constructed_series[[1]],
		constructed_series[[2]],
		as.double(acceleration),
		as.double(maximum)
		## splice:call:end
	)

	## readd rownames
	rownames(x) <- x_names

	## return indicator
	x
}

#' @usage NULL
#' @aliases parabolic_stop_and_reverse
#'
#' @export
parabolic_stop_and_reverse.data.frame <- function(
	x,
	cols,
	acceleration = 0.5,
	maximum = 0.75,
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases parabolic_stop_and_reverse
#'
#' @export
parabolic_stop_and_reverse.matrix <- function(
	x,
	cols,
	acceleration = 0.5,
	maximum = 0.75,
	...
) {
	as.matrix(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases parabolic_stop_and_reverse
#'
#' @export
parabolic_stop_and_reverse.plotly <- function(
	x,
	cols,
	acceleration = 0.5,
	maximum = 0.75,
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
		default = ~ high + low,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- parabolic_stop_and_reverse(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		acceleration = acceleration,
		maximum = maximum
	)

	## add conditional idx
	constructed_indicator[["idx"]] <- add_idx(
		constructed_series
	)

	## construct {plotly}-object
	## splice:plotly-assembly:start
	## identify bullish
	## signals
	bull <- (constructed_indicator$SAR < as.numeric(constructed_series[[2L]]))
	chart_theme <- .chart_theme()
	## determine colors
	##
	colors <- ifelse(
		bull,
		plotly::toRGB(chart_theme$bull_color, alpha = 0.8),
		plotly::toRGB(chart_theme$bear_color, alpha = 0.8)
	)

	## constuct chart
	## element
	plotly_object <- .plotting_environment[["main"]] <- plotly::add_trace(
		.plotting_environment[["main"]],
		data = constructed_indicator,
		x = ~idx,
		y = ~SAR,
		type = "scatter",
		mode = "markers",
		name = sprintf(
			"EPSAR(%f,%f)",
			1,
			1
		),
		inherit = FALSE,
		marker = list(
			size = 5,
			color = colors,
			line = list(
				color = "black",
				width = 1
			)
		)
	)
	## splice:plotly-assembly:end

	plotly_object
}
