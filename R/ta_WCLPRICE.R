#' @export
#' @family Price Transform
#'
#' @title Weighted Close Price
#' @templateVar .title Weighted Close Price
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun weighted_close_price
#' @templateVar .family Price Transform
#' @templateVar .formula ~high + low + close
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
#'
#' @template returns
weighted_close_price <- function(
	x,
	cols,
	na.bridge = FALSE,
	...
) {
	UseMethod("weighted_close_price")
}

#' @export
#' @usage NULL
#' @rdname weighted_close_price
#'
#' @aliases weighted_close_price
WCLPRICE <- weighted_close_price

#' @export
#' @usage NULL
#' @rdname weighted_close_price
#'
#' @aliases weighted_close_price
weightedClosePrice <- weighted_close_price

#' @usage NULL
#' @aliases weighted_close_price
#'
#' @export
weighted_close_price.default <- function(
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
		formula.default = ~ high + low + close,
		...
	)

	## extract rownames
	## for later attachment
	x_names <- index(constructed_series)

	## calculate indicator and
	## return as data.frame
	x <- .Call(
		C_impl_ta_WCLPRICE,
		constructed_series[[1]],
		constructed_series[[2]],
		constructed_series[[3]],
		as.logical(na.bridge)
	)

	## readd rownames
	set_index(x, x_names)

	## return indicator
	x
}

#' @usage NULL
#' @aliases weighted_close_price
#'
#' @export
weighted_close_price.data.frame <- function(
	x,
	cols,
	na.bridge = FALSE,
	...
) {
	as.data.frame(
		weighted_close_price.default(
			x = x,
			cols = cols,
			na.bridge = na.bridge,
			...
		)
	)
}

#' @usage NULL
#' @aliases weighted_close_price
#'
#' @export
weighted_close_price.matrix <- function(
	x,
	cols,
	na.bridge = FALSE,
	...
) {
	as.matrix(
		weighted_close_price.default(
			x = x,
			cols = cols,
			na.bridge = na.bridge,
			...
		)
	)
}

#' @usage NULL
#' @aliases weighted_close_price
#'
#' @export
weighted_close_price.xts <- function(
	x,
	cols,
	na.bridge = FALSE,
	...
) {
	as.xts(
		weighted_close_price.default(
			x = x,
			cols = cols,
			na.bridge = na.bridge,
			...
		)
	)
}

#' @usage NULL
WCLPRICE_lookback <- weightedClosePrice_lookback <- weighted_close_price_lookback <- function(
	x,
	cols,
	na.bridge = FALSE,
	...
) {
	.Call(
		C_impl_ta_WCLPRICE_lookback
	)
}
