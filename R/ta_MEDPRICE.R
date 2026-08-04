#' @export
#' @family Price Transform
#'
#' @title Median Price
#' @templateVar .title Median Price
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun median_price
#' @templateVar .family Price Transform
#' @templateVar .formula ~high + low
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
#'
#' @template returns
median_price <- function(
	x,
	cols,
	na.bridge = FALSE,
	...
) {
	UseMethod("median_price")
}

#' @export
#' @usage NULL
#' @rdname median_price
#'
#' @aliases median_price
MEDPRICE <- median_price

#' @export
#' @usage NULL
#' @rdname median_price
#'
#' @aliases median_price
medianPrice <- median_price

#' @usage NULL
#' @aliases median_price
#'
#' @export
median_price.default <- function(
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
		x = x,
		formula = cols,
		formula.default = ~ high + low,
		...
	)

	## extract rownames
	## for later attachment
	x_names <- index(constructed_series)

	## calculate indicator and
	## return as data.frame
	x <- .Call(
		C_impl_ta_MEDPRICE,
		constructed_series[[1]],
		constructed_series[[2]],
		as.logical(na.bridge)
	)

	## readd rownames
	set_index(x, x_names)

	## return indicator
	x
}

#' @usage NULL
#' @aliases median_price
#'
#' @export
median_price.data.frame <- function(
	x,
	cols,
	na.bridge = FALSE,
	...
) {
	as.data.frame(
		median_price.default(
			x = x,
			cols = cols,
			na.bridge = na.bridge,
			...
		)
	)
}

#' @usage NULL
#' @aliases median_price
#'
#' @export
median_price.matrix <- function(
	x,
	cols,
	na.bridge = FALSE,
	...
) {
	as.matrix(
		median_price.default(
			x = x,
			cols = cols,
			na.bridge = na.bridge,
			...
		)
	)
}

#' @usage NULL
#' @aliases median_price
#'
#' @export
median_price.xts <- function(
	x,
	cols,
	na.bridge = FALSE,
	...
) {
	as.xts(
		median_price.default(
			x = x,
			cols = cols,
			na.bridge = na.bridge,
			...
		)
	)
}

#' @usage NULL
MEDPRICE_lookback <- medianPrice_lookback <- median_price_lookback <- function(
	x,
	cols,
	na.bridge = FALSE,
	...
) {
	.Call(
		C_impl_ta_MEDPRICE_lookback
	)
}
