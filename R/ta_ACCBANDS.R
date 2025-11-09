#' @export
#' @family Overlap Study
#'
#' @title Acceleration Bands
#' @templateVar .title Acceleration Bands
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun acceleration_bands
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
#' @template returns
acceleration_bands <- function(
	x,
	cols,
	n = 10,
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
		"impl_ta_ACCBANDS",
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
#' @aliases acceleration_bands
#'
#' @export
acceleration_bands.data.frame <- function(
	x,
	cols,
	n = 10,
	...
) {
	as.data.frame(
		acceleration_bands.default(
			x = x,
			cols = cols,
			n = n,
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
	n = 10,
	...
) {
	as.matrix(
		acceleration_bands.default(
			x = x,
			cols = cols,
			n = n,
			...
		)
	)
}

#' @usage NULL
#' @aliases acceleration_bands
#'
#' @export
acceleration_bands.plotly <- function(
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
	constructed_indicator <- acceleration_bands(
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
	plotly_object <- .plotting_environment[["main"]] <- add_ribbons(
		plotly_object = .plotting_environment[["main"]],
		data = constructed_indicator,
		x = ~idx,
		y = ~MiddleBand,
		ymin = ~LowerBand,
		ymax = ~UpperBand,
		color = 'steelblue',
		alpha = 0.5,
		showlegend = TRUE,
		legendgroup = 'acceleration_band',
		name = c("Acceleration Bands", "B", "C"),
		dash = NULL
	)
	## splice:plotly-assembly:end

	plotly_object
}
