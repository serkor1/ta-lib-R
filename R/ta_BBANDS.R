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
#' @param std_up ([double]). Deviation multiplier for upper band
#' @param std_down ([double]). Deviation multiplier for lower band
## splice:documentation:end
#'
#' @template description
#' @template returns
bollinger_bands <- function(
	x,
	cols,
	ma = SMA(n = 10),
	std_up = 2,
	std_down = 2,
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
	std_up = 2,
	std_down = 2,
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
		as.double(std_up),
		as.double(std_down),
		ma$maType
		## splice:call:end
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
	std_up = 2,
	std_down = 2,
	...
) {
	as.data.frame(
		bollinger_bands.default(
			x = x,
			cols = cols,
			ma = ma,
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
	std_up = 2,
	std_down = 2,
	...
) {
	as.matrix(
		bollinger_bands.default(
			x = x,
			cols = cols,
			ma = ma,
			...
		)
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
	std_up = 2,
	std_down = 2,
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
		as.double(std_up),
		as.double(std_down),
		ma$maType
		## splice:numeric:end
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
	std_up = 2,
	std_down = 2,
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
	constructed_indicator <- bollinger_bands(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		ma = ma
	)

	## add conditional idx
	constructed_indicator[["idx"]] <- add_idx(
		constructed_series
	)

	## construct {plotly}-object
	## splice:plotly-assembly:start
	plotly_object <- .plotting_environment[["main"]] <- add_ribbons(
		plotly_object = .plotting_environment[["main"]],
		data = constructed_indicator,
		x = ~idx,
		y = ~MiddleBand,
		ymin = ~LowerBand,
		ymax = ~UpperBand,
		color = "steelblue",
		alpha = 0.5,
		showlegend = TRUE,
		legendgroup = "Bollinger Bands",
		name = c("Bollinger Bands", "middle", "upper"),
		dash = NULL
	)
	## splice:plotly-assembly:end

	plotly_object
}
