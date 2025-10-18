#' @export
#' @family Overlap Study
#'
#' @title Acceleration Bands
#'
#' @templateVar .title Acceleration Bands
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun acceleration_bands
#'
#' @returns
#' A [data.frame]- or [matrix]-object:
#'
#' \describe{
#'  \item{upper <[double]>}{The lower band.}
#'  \item{middle <[double]>}{The middle band.}
#'  \item{lower <[double]>}{The upper band.}
#' }
#'
#' @template description
acceleration_bands <- function(
	x,
	cols,
	n = 10,
	...
) {
	UseMethod("acceleration_bands")
}

#' @export
#'
#' @usage NULL
#'
#' @rdname acceleration_bands
#' @aliases acceleration_bands
ACCBANDS <- acceleration_bands

#' @usage NULL
#' @aliases acceleration_bands
#' @export
acceleration_bands.default <- function(
	x,
	cols,
	n = 10,
	...
) {
	## check input
	## cols if passed
	if (!missing(cols)) {
		assert(
			is.formula(cols),
			paste0(
				"'cols' has to be <",
				class(~s),
				">. ",
				"Got <",
				class(cols),
				">."
			)
		)
		assert(
			length(all.vars(cols)) == 3,
			paste0(
				"'cols' has to be length 3. ",
				"Got length ",
				length(all.vars(cols))
			)
		)
	}

	HLC <- series(
		x = cols,
		default = ~ open + high + close,
		data = x,
		...
	)

	assert(n >= 2)

	## 1) pass `x` assuming that it
	##    follows OHLC-V structure
	as.data.frame(
		.Call(
			"impl_ta_ACCBANDS",
			HLC[[1]],
			HLC[[2]],
			HLC[[3]],
			as.integer(n)
		)
	)
}

#' @usage NULL
#' @aliases acceleration_bands
#' @export
acceleration_bands.data.frame <- function(
	x,
	cols,
	n = 10,
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases acceleration_bands
#' @export
acceleration_bands.matrix <- function(
	x,
	cols,
	n = 10,
	...
) {
	as.matrix(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases acceleration_bands
#' @export
acceleration_bands.plotly <- function(
	x,
	cols,
	n = 10,
	color = "steelblue",
	alpha = 0.5,
	...
) {
	## prepare HLC series
	## for the acceleration bands
	HLC <- series(
		x = x,
		formula = cols,
		default = ~ open + high + close,
		...
	)

	## calculate indicator
	## and return as data.frame
	.indicator <- acceleration_bands.default(
		x = HLC,
		cols = rebuild_formula(
			names(HLC)
		),
		n = n
	)

	## add x-axis conditional on whether
	## the data have been subsetted or not
	.indicator$idx <- add_idx(
		HLC
	)

	## acceleration bands by itself
	## makes no sense - throw an error
	## if not provided
	if (is.null(.plotting_environment$main)) {
		stop("No existing chart found.", call. = FALSE)
	}

	## add upper, middle and lower bands
	## to the main chart - wrapped in local
	## to circumvent lazy evaluation.
	##
	## NOTE: Otherwise it will only evaluate
	##       and add the last element
	.plotting_environment$main <- add_ribbons(
		plotly_object = .plotting_environment$main,
		data = .indicator,
		x = ~idx,
		y = ~middle,
		ymin = ~lower,
		ymax = ~upper,
		color = color,
		alpha = alpha,
		showlegend = TRUE,
		legendgroup = 'acceleration_band',
		name = c("Acceleration Bands", "B", "C"),
		dash = NULL
	)

	.plotting_environment$main
}
