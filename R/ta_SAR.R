#' @export
#' @family Overlap Study
#'
#' @title Parabolic Stop and Reverse (SAR)
#' @templateVar .title Parabolic Stop and Reverse (SAR)
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun parabolic_stop_and_reverse
#' @templateVar .family Overlap Study
#' @templateVar .formula ~high+low
#'
## splice:documentation:start
#' @param acceleration ([double]). Acceleration factor used up to the maximum value.
#' @param maximum ([double]). Acceleration factor maximum value.
## splice:documentation:end
#'
#' @template description
#' @template returns
parabolic_stop_and_reverse <- function(
	x,
	cols,
	acceleration = 0.02,
	maximum = 0.2,
	na.bridge = FALSE,
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
	acceleration = 0.02,
	maximum = 0.2,
	na.bridge = FALSE,
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
		C_impl_ta_SAR,
		## splice:call:start
		constructed_series[[1]],
		constructed_series[[2]],
		as.double(acceleration),
		as.double(maximum),
		## splice:call:end
		as.logical(na.bridge)
	)

	## readd rownames
	set_rownames(x, x_names)

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
	acceleration = 0.02,
	maximum = 0.2,
	na.bridge = FALSE,
	...
) {
	map_dfr(
		parabolic_stop_and_reverse.default(
			x = x,
			cols = cols,
			acceleration = acceleration,
			maximum = maximum,
			na.bridge = na.bridge,
			...
		)
	)
}

#' @usage NULL
#' @aliases parabolic_stop_and_reverse
#'
#' @export
parabolic_stop_and_reverse.matrix <- function(
	x,
	cols,
	acceleration = 0.02,
	maximum = 0.2,
	na.bridge = FALSE,
	...
) {
	parabolic_stop_and_reverse.default(
		x = x,
		cols = cols,
		acceleration = acceleration,
		maximum = maximum,
		na.bridge = na.bridge,
		...
	)
}


#' @usage NULL
#' @aliases parabolic_stop_and_reverse
#'
#' @export
parabolic_stop_and_reverse.plotly <- function(
	x,
	cols,
	acceleration = 0.02,
	maximum = 0.2,
	na.bridge = FALSE,
	## splice:optional-plotly:start
	## splice:optional-plotly:end
	...
) {
	## check that input value
	## 'x' is <plotly>-object
	assert_plotly_object(x)

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
		maximum = maximum,
		na.bridge = TRUE
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
	## determine colors
	##
	colors <- ifelse(
		bull,
		plotly::toRGB(.chart_variables$bullish_body, alpha = 0.8),
		plotly::toRGB(.chart_variables$bearish_body, alpha = 0.8)
	)

	## constuct chart
	## element
	name <- "Parabolic Stop and Reverse"
	traces <- list(
		list(
			y = ~SAR,
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

	state <- .chart_state()
	plotly_object <- build_plotly(
		init = state[["main"]],
		traces = traces,
		decorators = list(),
		name = get0(
			x = "name",
			ifnotfound = NULL
		),
		data = constructed_indicator
	)
	state[["main"]] <- plotly_object

	plotly_object
}

#' @usage NULL
#' @aliases parabolic_stop_and_reverse
#'
#' @export
parabolic_stop_and_reverse.ggplot <- function(
	x,
	cols,
	acceleration = 0.02,
	maximum = 0.2,
	na.bridge = FALSE,
	## splice:optional-ggplot:start
	## splice:optional-ggplot:end
	...
) {
	## check ggplot2 availability
	assert_ggplot2()

	## check that input value
	## 'cols' is a <formula>-objet
	if (!missing(cols)) {
		assert_formula(cols)
	}

	## construct series from
	## {ggplot}-object
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
		maximum = maximum,
		na.bridge = TRUE
	)

	## add conditional idx
	constructed_indicator[["idx"]] <- add_idx(
		constructed_series
	)

	## construct {ggplot2}-object
	## splice:ggplot-assembly:start
	layers <- list(
		list(y = "SAR", geom = "point")
	)
	name <- "SAR"
	## splice:ggplot-assembly:end

	state <- .chart_state()
	ggplot_object <- build_ggplot(
		init = state[["main"]],
		layers = layers,
		decorators = list(),
		name = get0(
			x = "name",
			ifnotfound = NULL
		),
		data = constructed_indicator
	)
	state[["main"]] <- ggplot_object

	ggplot_object
}
