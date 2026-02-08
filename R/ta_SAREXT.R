#' @export
#' @family Overlap Study
#'
#' @title Parabolic Stop and Reverse (SAR) - Extended
#' @templateVar .title Parabolic Stop and Reverse (SAR) - Extended
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun extended_parabolic_stop_and_reverse
#' @templateVar .family Overlap Study
#' @templateVar .formula ~high+low
#'
## splice:documentation:start
#' @param init ([double]). Start value and direction. 0 for Auto, >0 for Long, <0 for Short.
#' @param offset ([double]). Offset added/removed to initial stop on short/long reversal.
#' @param init_long ([double]). Acceleration factor initial value for the Long direction.
#' @param long ([double]). Acceleration factor for the Long direction.
#' @param max_long ([double]). Acceleration factor maximum value for the Long direction.
#' @param init_short ([double]). Acceleration factor initial value for the Short direction.
#' @param short ([double]). Acceleration factor for the Short direction.
#' @param max_short ([double]). Acceleration factor maximum value for the Short direction.
## splice:documentation:end
#'
#' @template description
#' @template returns
extended_parabolic_stop_and_reverse <- function(
	x,
	cols,
	init = 0,
	offset = 0,
	init_long = 0,
	long = 0,
	max_long = 0,
	init_short = 0,
	short = 0,
	max_short = 0,
	...
) {
	UseMethod("extended_parabolic_stop_and_reverse")
}

#' @export
#' @usage NULL
#' @rdname extended_parabolic_stop_and_reverse
#'
#' @aliases extended_parabolic_stop_and_reverse
SAREXT <- extended_parabolic_stop_and_reverse

#' @usage NULL
#' @aliases extended_parabolic_stop_and_reverse
#'
#' @export
extended_parabolic_stop_and_reverse.default <- function(
	x,
	cols,
	init = 0,
	offset = 0,
	init_long = 0,
	long = 0,
	max_long = 0,
	init_short = 0,
	short = 0,
	max_short = 0,
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
		"impl_ta_SAREXT",
		## splice:call:start
		constructed_series[[1]],
		constructed_series[[2]],
		init,
		offset,
		init_long,
		long,
		max_long,
		init_short,
		short,
		max_short
		## splice:call:end
	)

	## readd rownames
	set_rownames(x, x_names)

	## return indicator
	x
}

#' @usage NULL
#' @aliases extended_parabolic_stop_and_reverse
#'
#' @export
extended_parabolic_stop_and_reverse.data.frame <- function(
	x,
	cols,
	init = 0,
	offset = 0,
	init_long = 0,
	long = 0,
	max_long = 0,
	init_short = 0,
	short = 0,
	max_short = 0,
	...
) {
	map_dfr(
		extended_parabolic_stop_and_reverse.default(
			x = x,
			cols = cols,
			init = init,
			offset = offset,
			init_long = init_long,
			long = long,
			max_long = max_long,
			init_short = init_short,
			short = short,
			max_short = max_short,
			...
		)
	)
}

#' @usage NULL
#' @aliases extended_parabolic_stop_and_reverse
#'
#' @export
extended_parabolic_stop_and_reverse.matrix <- function(
	x,
	cols,
	init = 0,
	offset = 0,
	init_long = 0,
	long = 0,
	max_long = 0,
	init_short = 0,
	short = 0,
	max_short = 0,
	...
) {
	extended_parabolic_stop_and_reverse.default(
		x = x,
		cols = cols,
		init = init,
		offset = offset,
		init_long = init_long,
		long = long,
		max_long = max_long,
		init_short = init_short,
		short = short,
		max_short = max_short,
		...
	)
}

#' @usage NULL
#' @aliases extended_parabolic_stop_and_reverse
#'
#' @export
extended_parabolic_stop_and_reverse.plotly <- function(
	x,
	cols,
	init = 0,
	offset = 0,
	init_long = 0,
	long = 0,
	max_long = 0,
	init_short = 0,
	short = 0,
	max_short = 0,
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
	constructed_indicator <- extended_parabolic_stop_and_reverse(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		init = init,
		offset = offset,
		init_long = init_long,
		long = long,
		max_long = max_long,
		init_short = init_short,
		short = short,
		max_short = max_short
	)

	## add conditional idx
	constructed_indicator[["idx"]] <- add_idx(
		constructed_series
	)

	## construct {plotly}-object
	## splice:plotly-assembly:start
	## identify bullish
	## signals
	bull <- (constructed_indicator$SAR[
		-c(1:attr(constructed_indicator, "lookback"))
	] <
		as.numeric(
			constructed_series[[2L]][
				-c(1:attr(constructed_indicator, "lookback"))
			]
		))
	chart_theme <- .chart_theme()
	## determine colors
	##
	colors <- ifelse(
		bull,
		plotly::toRGB(.chart_variables$bullish_body, alpha = 0.8),
		plotly::toRGB(.chart_variables$bearish_body <- "#A9A9A9", alpha = 0.8)
	)

	## constuct chart
	## element
	name <- "Parabolic Stop and Reverse (Extended)"
	traces <- list(
		list(
			y = ~SAREXT,
			type = "scatter",
			mode = "markers",
			color = colors,
			marker = list(
				size = 5,
				color = colors,
				line = list(
					color = "black",
					width = 0.75
				)
			)
		)
	)
	## splice:plotly-assembly:end

	plotly_object <- .plotting_environment[["main"]] <- build_plotly(
		init = .plotting_environment[["main"]],
		traces = traces,
		decorators = list(),
		name = get0(
			x = "name",
			ifnotfound = NULL
		),
		data = constructed_indicator
	)

	plotly_object
}
