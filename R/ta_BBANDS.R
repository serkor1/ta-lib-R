#' @export
#' @family Overlap Study
#'
#' @title Bollinger Bands
#'
#' @templateVar .title Bollinger Bands
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun bollinger_bands
#'
#' @param ma A function call to a moving average function.
#' @param up,down A pair of [double] for upper and lower standard deviations.
#'
#' @returns
#' A [data.frame]- or [matrix]-object with the format:
#'
#' \describe{
#'  \item{upper}{[double]. The lower band.}
#'  \item{middle}{[double]. The middle band.}
#'  \item{lower}{[double]. The upper band.}
#' }
#'
#' @template description
bollinger_bands <- function(
	x,
	cols,
	ma = SMA(n = 10),
	up = 2,
	down = 2,
	...
) {
	UseMethod(
		generic = "bollinger_bands"
	)
}

#' @export
#'
#' @usage NULL
#'
#' @rdname bollinger_bands
#' @aliases bollinger_bands
BBANDS <- bollinger_bands

#' @usage NULL
#' @aliases bollinger_bands
#' @export
bollinger_bands.default <- function(
	x,
	cols,
	ma = SMA(n = 10),
	up = 2,
	down = 2,
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
			length(all.vars(cols)) == 1,
			paste0(
				"'cols' has to be length 1. ",
				"Got length ",
				length(all.vars(cols))
			)
		)
	}

	## default behaviour is to
	## coerce to a `matrix` check that
	## it is double and then pass to
	## C-side.
	x <- series(
		x = cols,
		default = ~open,
		data = x,
		...
	)

	## 1) pass `x` assuming that it
	##    follows OHLC-V structure
	as.data.frame(
		.Call(
			"impl_ta_BBANDS",
			as.double(x[[1]]),
			ma$n,
			as.numeric(up),
			as.numeric(down),
			as.integer(ma$maType)
		)
	)
}

#' @usage NULL
#' @aliases bollinger_bands
#' @export
bollinger_bands.numeric <- function(
	x,
	cols,
	ma = SMA(n = 10),
	up = 2,
	down = 2,
	...
) {
	## determine branch
	## if its a matrix call
	## matrix method and end the function
	##
	## NOTE: this is necessary as matrix are
	##       internally doubles
	if (is.matrix(x)) {
		output <- NextMethod()

		return(output)
	}

	## treat 'x' as a vector
	##
	if (!missing(cols)) {
		warning(
			"'cols' have been passed but is unused in for vectors"
		)
	}

	as.data.frame(
		.Call(
			"impl_ta_BBANDS",
			as.double(x),
			ma$n,
			as.numeric(up),
			as.numeric(down),
			as.integer(ma$maType)
		)
	)
}

#' @usage NULL
#' @aliases bollinger_bands
#' @export
bollinger_bands.data.frame <- function(
	x,
	cols,
	ma = SMA(n = 10),
	up = 2,
	down = 2,
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases bollinger_bands
#' @export
bollinger_bands.matrix <- function(
	x,
	cols,
	ma = SMA(n = 10),
	up = 2,
	down = 2,
	...
) {
	as.matrix(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases bollinger_bands
#' @export
bollinger_bands.plotly <- function(
	x,
	cols,
	ma = SMA(n = 10),
	up = 2,
	down = 2,
	color = "steelblue",
	alpha = 0.5,
	...
) {
	## prepare univariate
	## series for the bollinger
	## bands
	x <- series(
		x = x,
		formula = cols,
		default = ~open,
		...
	)

	## calculate indicator
	## and return as data.frame
	.indicator <- bollinger_bands.default(
		x = x,
		cols = rebuild_formula(
			names(x)
		),
		ma = ma,
		up = up,
		down = down
	)

	## add x-axis conditional on whether
	## the data have been subsetted or not
	.indicator$idx <- add_idx(
		x
	)

	## acceleration bands by itself
	## makes no sense - throw an error
	## if not provided
	if (is.null(.plotting_environment$main)) {
		stop("No existing chart found.", call. = FALSE)
	}

	## constuct chart
	## element
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
		legendgroup = "Bollinger Bands",
		name = c("Bollinger Bands", "middle", "upper"),
		dash = NULL
	)

	.plotting_environment$main
}
