#' @export
#' @family Overlap Study
#'
#' @title Acceleration Bands
#' @templateVar .title Acceleration Bands
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun acceleration_bands
#' @templateVar .family Overlap Study
#' @templateVar .formula ~ high + low + close
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
#' @template returns
acceleration_bands <- function(
	x,
	cols,
	n = 20,
	na.bridge = FALSE,
	...
) {
	UseMethod("acceleration_bands")
}

#' @export
#' @usage NULL
#' @rdname acceleration_bands
#'
#' @aliases acceleration_bands
ACCBANDS <- acceleration_bands

#' @usage NULL
#' @aliases acceleration_bands
#'
#' @export
acceleration_bands.default <- function(
	x,
	cols,
	n = 20,
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
		C_impl_ta_ACCBANDS,
		## splice:call:start
		constructed_series[[1]],
		constructed_series[[2]],
		constructed_series[[3]],
		as.integer(n),
		## splice:call:end
		as.logical(na.bridge)
	)

	## readd rownames
	set_rownames(x, x_names)

	## return indicator
	x
}

#' @usage NULL
#' @aliases acceleration_bands
#'
#' @export
acceleration_bands.data.frame <- function(
	x,
	cols,
	n = 20,
	na.bridge = FALSE,
	...
) {
	map_dfr(
		acceleration_bands.default(
			x = x,
			cols = cols,
			n = n,
			na.bridge = na.bridge,
			...
		)
	)
}

#' @usage NULL
#' @aliases acceleration_bands
#'
#' @export
acceleration_bands.matrix <- function(
	x,
	cols,
	n = 20,
	na.bridge = FALSE,
	...
) {
	acceleration_bands.default(
		x = x,
		cols = cols,
		n = n,
		na.bridge = na.bridge,
		...
	)
}


#' @usage NULL
#' @aliases acceleration_bands
#'
#' @export
acceleration_bands.plotly <- function(
	x,
	cols,
	n = 20,
	na.bridge = FALSE,
	## splice:optional-plotly:start
	color = "steelblue",
	alpha = 0.2,
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
		default = ~ high + low + close,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- acceleration_bands(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		n = n,
		na.bridge = TRUE
	)

	## add conditional idx
	constructed_indicator[["idx"]] <- add_idx(
		constructed_series
	)

	## construct {plotly}-object
	## splice:plotly-assembly:start
	name <- label(
		"Acceleration Bands",
		n
	)

	traces <- list(
		list(
			y = ~UpperBand,
			name = "Upper Acceleration Band",
			showlegend = FALSE
		),
		list(
			y = ~MiddleBand,
			name = "SMA",
			fill = "tonexty",
			showlegend = TRUE
		),
		list(
			y = ~LowerBand,
			name = "Lower Acceleration Band",
			fill = "tonexty",
			showlegend = FALSE
		)
	)

	traces <- modify_traces(
		traces,
		fillcolor = plotly::toRGB(
			color,
			alpha
		),
		line = list(
			color = color
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
#' @aliases acceleration_bands
#'
#' @export
acceleration_bands.ggplot <- function(
	x,
	cols,
	n = 20,
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
		default = ~ high + low + close,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- acceleration_bands(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		n = n,
		na.bridge = TRUE
	)

	## add conditional idx
	constructed_indicator[["idx"]] <- add_idx(
		constructed_series
	)

	## construct {ggplot2}-object
	## splice:ggplot-assembly:start
	layers <- list(
		list(y = "UpperBand"),
		list(y = "MiddleBand"),
		list(y = "LowerBand"),
		list(
			geom = "ribbon",
			y = "MiddleBand",
			y_upper = "UpperBand",
			y_lower = "LowerBand"
		)
	)
	name <- label("ACCBANDS", n)
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
