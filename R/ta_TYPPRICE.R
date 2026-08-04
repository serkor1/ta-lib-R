#' @export
#' @family Price Transform
#'
#' @title Typical Price
#' @templateVar .title Typical Price
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun typical_price
#' @templateVar .family Price Transform
#' @templateVar .formula ~high + low + close
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
#'
#' @template returns
typical_price <- function(
	x,
	cols,
	na.bridge = FALSE,
	...
) {
	UseMethod("typical_price")
}

#' @export
#' @usage NULL
#' @rdname typical_price
#'
#' @aliases typical_price
TYPPRICE <- typical_price

#' @export
#' @usage NULL
#' @rdname typical_price
#'
#' @aliases typical_price
typicalPrice <- typical_price

#' @usage NULL
#' @aliases typical_price
#'
#' @export
typical_price.default <- function(
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
		C_impl_ta_TYPPRICE,
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
#' @aliases typical_price
#'
#' @export
typical_price.data.frame <- function(
	x,
	cols,
	na.bridge = FALSE,
	...
) {
	as.data.frame(
		typical_price.default(
			x = x,
			cols = cols,
			na.bridge = na.bridge,
			...
		)
	)
}

#' @usage NULL
#' @aliases typical_price
#'
#' @export
typical_price.matrix <- function(
	x,
	cols,
	na.bridge = FALSE,
	...
) {
	as.matrix(
		typical_price.default(
			x = x,
			cols = cols,
			na.bridge = na.bridge,
			...
		)
	)
}

#' @usage NULL
#' @aliases typical_price
#'
#' @export
typical_price.xts <- function(
	x,
	cols,
	na.bridge = FALSE,
	...
) {
	as.xts(
		typical_price.default(
			x = x,
			cols = cols,
			na.bridge = na.bridge,
			...
		)
	)
}

#' @usage NULL
TYPPRICE_lookback <- typicalPrice_lookback <- typical_price_lookback <- function(
	x,
	cols,
	na.bridge = FALSE,
	...
) {
	.Call(
		C_impl_ta_TYPPRICE_lookback
	)
}
