#' @export
#' @family Overlap Study
#'
#' @title Bollinger Bands
#' @templateVar .title Bollinger Bands
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun bollinger_bands
#' @templateVar .family Overlap Study
#' @templateVar .formula ~close
#'
## splice:documentation:start
#' @param ma ([list]). The type of Moving Average (MA) used for the `MiddleBand`. [SMA] by default.
#' @param sd ([double]). Deviation multiplier for the upper and lower band.
#' @param sd_up ([double]). Optional. Deviation multiplier for upper band
#' @param sd_down ([double]). Optional. Deviation multiplier for lower band
## splice:documentation:end
#'
#' @template description
#' @template returns
bollinger_bands <- function(
	x,
	cols,
	ma = SMA(n = 10),
	sd = 2,
	sd_down,
	sd_up,
	na.rm = FALSE,
	...
) {
	UseMethod("bollinger_bands")
}

#' @export
#' @usage NULL
#' @rdname bollinger_bands
#'
#' @aliases bollinger_bands
BBANDS <- bollinger_bands

#' @usage NULL
#' @aliases bollinger_bands
#'
#' @export
bollinger_bands.default <- function(
	x,
	cols,
	ma = SMA(n = 10),
	sd = 2,
	sd_down,
	sd_up,
	na.rm = FALSE,
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
	x_names <- rownames(constructed_series)

	## calculate indicator and
	## return as data.frame
	x <- .Call(
		"impl_ta_BBANDS",
		## splice:call:start
		constructed_series[[1]],
		ma$n,
		as.double(sd_up %or% sd),
		as.double(sd_down %or% sd),
		ma$maType,
		## splice:call:end
		as.logical(na.rm)
	)

	## readd rownames
	set_rownames(x, x_names)

	## return indicator
	x
}

#' @usage NULL
#' @aliases bollinger_bands
#'
#' @export
bollinger_bands.data.frame <- function(
	x,
	cols,
	ma = SMA(n = 10),
	sd = 2,
	sd_down,
	sd_up,
	na.rm = FALSE,
	...
) {
	map_dfr(
		bollinger_bands.default(
			x = x,
			cols = cols,
			ma = ma,
			sd = sd,
			sd_down = sd_down,
			sd_up = sd_up,
			na.rm = na.rm,
			...
		)
	)
}

#' @usage NULL
#' @aliases bollinger_bands
#'
#' @export
bollinger_bands.matrix <- function(
	x,
	cols,
	ma = SMA(n = 10),
	sd = 2,
	sd_down,
	sd_up,
	na.rm = FALSE,
	...
) {
	bollinger_bands.default(
		x = x,
		cols = cols,
		ma = ma,
		sd = sd,
		sd_down = sd_down,
		sd_up = sd_up,
		na.rm = na.rm,
		...
	)
}


#' @usage NULL
#' @aliases bollinger_bands
#'
#' @export
bollinger_bands.numeric <- function(
	x,
	cols,
	ma = SMA(n = 10),
	sd = 2,
	sd_down,
	sd_up,
	na.rm = FALSE,
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
		"impl_ta_BBANDS",
		## splice:numeric:start
		as.double(x),
		ma$n,
		as.double(sd_up %or% sd),
		as.double(sd_down %or% sd),
		ma$maType,
		## splice:numeric:end
		as.logical(na.rm)
	)

	## check if it has 'dims'
	## and convert to double if
	## not to honor the 'type-safety'-esque
	## approach
	##
	## NOTE: this adds a few ns overhead but
	##       its a robust alternative to code it
	##       manually. Any suggestions are welcome
	if (is.null(dim(x))) {
		x <- as.double(x)
	}

	x
}


#' @usage NULL
#' @aliases bollinger_bands
#'
#' @export
bollinger_bands.plotly <- function(
	x,
	cols,
	ma = SMA(n = 10),
	sd = 2,
	sd_down,
	sd_up,
	## splice:optional-plotly:start
	color = "steelblue",
	alpha = 0.2,
	## splice:optional-plotly:end
	na.rm = FALSE,
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
	constructed_indicator <- bollinger_bands(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		ma = ma,
		sd = sd,
		sd_down = sd_down,
		sd_up = sd_up
	)

	## add conditional idx
	constructed_indicator[["idx"]] <- add_idx(
		constructed_series
	)

	## construct {plotly}-object
	## splice:plotly-assembly:start

	## standard deviations
	sd_down <- as.double(sd_down %or% sd)
	sd_up <- as.double(sd_up %or% sd)

	if (sd_down == sd_up) {
		name <- label(
			"Bollinger Bands",
			ma$n,
			sd_up
		)
	} else {
		name <- label(
			"Bollinger Bands",
			ma$n,
			sd_up,
			sd_down
		)
	}

	traces <- list(
		list(
			y = ~UpperBand,
			name = paste("Upper Bollinger Band", paste0("+", sd_up, " sd")),
			showlegend = FALSE
		),
		list(
			y = ~MiddleBand,
			name = sub("\\(.*$", "", input_name(substitute(ma)), perl = TRUE),
			fill = "tonexty"
		),
		list(
			y = ~LowerBand,
			name = paste("Lower Bollinger Band", paste0("-", sd_down, " sd")),
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

	plotly_object <- .chart_environment[["main"]] <- build_plotly(
		init = .chart_environment[["main"]],
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
