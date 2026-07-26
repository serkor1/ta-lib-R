#' @export
#' @family Overlap Studies
#'
#' @title Midpoint Price over period
#' @templateVar .title Midpoint Price over period
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun midpoint_price
#' @templateVar .family Overlap Studies
#' @templateVar .formula ~high + low
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
#' @template returns
midpoint_price <- function(
	x,
	cols,
	timePeriod = 14,
	na.bridge = FALSE,
	...
) {
	UseMethod("midpoint_price")
}

#' @export
#' @usage NULL
#' @rdname midpoint_price
#'
#' @aliases midpoint_price
MIDPRICE <- midpoint_price

#' @usage NULL
#' @aliases midpoint_price
#'
#' @export
midpoint_price.default <- function(
	x,
	cols,
	timePeriod = 14,
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
		default_formula = ~ high + low,
		data = x,
		...
	)

	## extract rownames
	## for later attachment
	x_names <- rownames(constructed_series)

	## calculate indicator and
	## return as data.frame
	x <- .Call(
		C_impl_ta_MIDPRICE,
		constructed_series[[1]],
		constructed_series[[2]],
		as.integer(timePeriod),
		as.logical(na.bridge)
	)

	## readd rownames
	set_rownames(x, x_names)

	## return indicator
	x
}

#' @usage NULL
#' @aliases midpoint_price
#'
#' @export
midpoint_price.data.frame <- function(
	x,
	cols,
	timePeriod = 14,
	na.bridge = FALSE,
	...
) {
	map_dfr(
		midpoint_price.default(
			x = x,
			cols = cols,
			timePeriod = timePeriod,
			na.bridge = na.bridge,
			...
		)
	)
}

#' @usage NULL
#' @aliases midpoint_price
#'
#' @export
midpoint_price.matrix <- function(
	x,
	cols,
	timePeriod = 14,
	na.bridge = FALSE,
	...
) {
	midpoint_price.default(
		x = x,
		cols = cols,
		timePeriod = timePeriod,
		na.bridge = na.bridge,
		...
	)
}

#' @usage NULL
midpoint_price_lookback <- function(
	x,
	cols,
	timePeriod = 14,
	na.bridge = FALSE,
	...
) {
	.Call(
		C_impl_ta_MIDPRICE_lookback,
		as.integer(timePeriod)
	)
}
