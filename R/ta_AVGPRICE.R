#' @export
#' @family Price Transform
#'
#' @title Average Price
#' @templateVar .title Average Price
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun average_price
#' @templateVar .family Price Transform
#' @templateVar .formula ~open + high + low + close
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
#' @template returns
average_price <- function(
	x,
	cols,
	na.bridge = FALSE,
	...
) {
	UseMethod("average_price")
}

#' @export
#' @usage NULL
#' @rdname average_price
#'
#' @aliases average_price
AVGPRICE <- average_price

#' @usage NULL
#' @aliases average_price
#'
#' @export
average_price.default <- function(
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
		x = cols,
		default = ~ open + high + low + close,
		data = x,
		...
	)

	## extract rownames
	## for later attachment
	x_names <- rownames(constructed_series)

	## calculate indicator and
	## return as data.frame
	x <- .Call(
		C_impl_ta_AVGPRICE,
		## splice:call:start
		constructed_series[[1]],
		constructed_series[[2]],
		constructed_series[[3]],
		constructed_series[[4]],
		## splice:call:end
		as.logical(na.bridge)
	)

	## readd rownames
	set_rownames(x, x_names)

	## return indicator
	x
}

#' @usage NULL
#' @aliases average_price
#'
#' @export
average_price.data.frame <- function(
	x,
	cols,
	na.bridge = FALSE,
	...
) {
	map_dfr(
		average_price.default(
			x = x,
			cols = cols,
			na.bridge = na.bridge,
			...
		)
	)
}

#' @usage NULL
#' @aliases average_price
#'
#' @export
average_price.matrix <- function(
	x,
	cols,
	na.bridge = FALSE,
	...
) {
	average_price.default(
		x = x,
		cols = cols,
		na.bridge = na.bridge,
		...
	)
}
