#' @export
#' @family Overlap Study
#'
#' @title Bollinger Bands
#' @templateVar .title Bollinger Bands
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun bollinger_bands
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
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
	x_names <- rownames(x)

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
	rownames(x) <- x_names

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
		NextMethod()
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
		NextMethod()
	)
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
		ma = ma,
		std_up = std_up,
		std_down = std_down
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
		y = ~middle,
		ymin = ~lower,
		ymax = ~upper,
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
