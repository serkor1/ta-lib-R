#' @export
#' @family Cycle Indicators
#'
#' @title Hilbert Transform - SineWave
#' @templateVar .title Hilbert Transform - SineWave
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun sine_wave
#' @templateVar .family Cycle Indicators
#' @templateVar .formula ~close
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
#'
#' @template returns
sine_wave <- function(
	x,
	cols,
	na.bridge = FALSE,
	...
) {
	UseMethod("sine_wave")
}

#' @export
#' @usage NULL
#' @rdname sine_wave
#'
#' @aliases sine_wave
HT_SINE <- sine_wave

#' @export
#' @usage NULL
#' @rdname sine_wave
#'
#' @aliases sine_wave
sineWave <- sine_wave

#' @usage NULL
#' @aliases sine_wave
#'
#' @export
sine_wave.default <- function(
	x,
	cols,
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
		default_formula = ~close,
		data = x,
		...
	)

	## extract rownames
	## for later attachment
	x_names <- rownames(constructed_series)

	## calculate indicator and
	## return as data.frame
	x <- .Call(
		C_impl_ta_HT_SINE,
		constructed_series[[1]],
		as.logical(na.bridge)
	)

	## readd rownames
	set_rownames(x, x_names)

	## return indicator
	x
}

#' @usage NULL
#' @aliases sine_wave
#'
#' @export
sine_wave.data.frame <- function(
	x,
	cols,
	na.bridge = FALSE,
	...
) {
	map_dfr(
		sine_wave.default(
			x = x,
			cols = cols,
			na.bridge = na.bridge,
			...
		)
	)
}

#' @usage NULL
#' @aliases sine_wave
#'
#' @export
sine_wave.matrix <- function(
	x,
	cols,
	na.bridge = FALSE,
	...
) {
	sine_wave.default(
		x = x,
		cols = cols,
		na.bridge = na.bridge,
		...
	)
}

#' @usage NULL
HT_SINE_lookback <- sineWave_lookback <- sine_wave_lookback <- function(
	x,
	cols,
	na.bridge = FALSE,
	...
) {
	.Call(
		C_impl_ta_HT_SINE_lookback
	)
}

#' @usage NULL
#' @aliases sine_wave
#'
#' @export
sine_wave.numeric <- function(
	x,
	cols,
	na.bridge = FALSE,
	...
) {
	## warn if 'cols' have been
	## passed just to make sure
	## the user knows its not possible
	## or relevant
	if (!missing(cols)) {
		warning("'cols' is passed but is unused for vectors.")
	}

	## pass the argument directly
	## to 'C'
	x <- .Call(
		C_impl_ta_HT_SINE,
		as.double(x),
		as.logical(na.bridge)
	)

	if (dim(x)[2] == 1L) {
		dim(x) <- NULL
	}

	x
}

#' @usage NULL
#' @aliases sine_wave
#'
#' @export
sine_wave.plotly <- function(
	x,
	cols,
	na.bridge = FALSE,
	## splice:optional-plotly:start
	## splice:optional-plotly:end
	title,
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
		default_formula = ~close,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- sine_wave(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		na.bridge = TRUE
	)

	## the constructed indicator
	## always returns excpected
	## columns which can be passed
	## down to add_last_values()
	values_to_extract <- colnames(constructed_indicator)

	## add conditional idx
	constructed_indicator[["idx"]] <- add_idx(
		constructed_series
	)

	## construct {plotly}-object
	## splice:plotly-assembly:start
	name <- sprintf("Hilbert Transform - SineWave")

	decorators <- list(
		function(p) add_limit_ly(p, y_range = c(-1, 1))
	)

	traces <- list(
		list(
			y = ~Sine,
			name = "Sine",
			legendgroup = name,
			legendgrouptitle = list(text = name)
		),
		list(
			y = ~LeadSine,
			name = "Lead Sine",
			legendgroup = name,
			legendgrouptitle = list(text = name)
		)
	)
	## splice:plotly-assembly:end

	plotly_object <- add_last_value_ly(
		build_plotly(
			init = plotly_init(),
			traces = traces,
			decorators = get0(
				x = "decorators",
				ifnotfound = list()
			),
			name = get0(
				x = "name",
				ifnotfound = NULL
			),
			data = constructed_indicator,
			title = if (missing(title)) {
				"Hilbert Transform - SineWave"
			} else {
				title
			}
		),
		data = constructed_indicator[, values_to_extract, drop = FALSE],
		values_to_extract = values_to_extract,
		name = get0(x = "name", ifnotfound = NULL)
	)

	state <- .chart_state()
	state$sub <- c(state$sub, list(plotly_object))

	plotly_object
}

#' @usage NULL
#' @aliases sine_wave
#'
#' @export
sine_wave.ggplot <- function(
	x,
	cols,
	na.bridge = FALSE,
	title,
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
		default_formula = ~close,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- sine_wave(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		na.bridge = TRUE
	)

	## the constructed indicator
	## always returns expected
	## columns which can be passed
	## down to add_last_value_gg()
	values_to_extract <- colnames(constructed_indicator)

	## add conditional idx
	constructed_indicator[["idx"]] <- add_idx(
		constructed_series
	)

	## construct {ggplot2}-object
	## splice:ggplot-assembly:start
	decorators <- list(
		function(p) add_limit_gg(p, c(-1, 1))
	)
	layers <- list(
		list(y = "Sine", name = "Sine"),
		list(y = "LeadSine", name = "Lead Sine")
	)
	name <- "SineWave"
	## splice:ggplot-assembly:end

	ggplot_object <- add_last_value_gg(
		build_ggplot(
			init = ggplot_init(),
			layers = layers,
			decorators = get0(
				x = "decorators",
				ifnotfound = list()
			),
			name = get0(
				x = "name",
				ifnotfound = NULL
			),
			data = constructed_indicator,
			title = if (missing(title)) {
				"Hilbert Transform - SineWave"
			} else {
				title
			}
		),
		data = constructed_indicator[, values_to_extract, drop = FALSE],
		values_to_extract = values_to_extract,
		name = get0(x = "name", ifnotfound = NULL)
	)

	state <- .chart_state()
	state$sub <- c(state$sub, list(ggplot_object))

	ggplot_object
}
