#' @export
#' @family Price Transform
#'
#' @title Midpoint Price
#' @templateVar .title Midpoint Price
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun midpoint_price
#' @templateVar .family Price Transform
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
	n = 14,
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
	n = 14,
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
		default = ~ high + low,
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
		## splice:call:start
		constructed_series[[1]],
		constructed_series[[2]],
		as.integer(n),
		## splice:call:end
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
	n = 14,
	na.bridge = FALSE,
	...
) {
	map_dfr(
		midpoint_price.default(
			x = x,
			cols = cols,
			n = n,
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
	n = 14,
	na.bridge = FALSE,
	...
) {
	midpoint_price.default(
		x = x,
		cols = cols,
		n = n,
		na.bridge = na.bridge,
		...
	)
}
