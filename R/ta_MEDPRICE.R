#' @export
#' @family Price Transform
#'
#' @title Median Price
#' @templateVar .title Median Price
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun median_price
#' @templateVar .family Price Transform
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
#' @template returns
median_price <- function(
	x,
	cols,
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

#' @usage NULL
#' @aliases median_price
#'
#' @export
median_price.default <- function(
	x,
	cols,
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
		"impl_ta_MEDPRICE",
		## splice:call:start
		constructed_series[[1]],
		constructed_series[[2]]
		## splice:call:end
	)

	## readd rownames
	set_rownames(x, x_names)

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
	...
) {
	as.data.frame(
		median_price.default(
			x = x,
			cols = cols,
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
	...
) {
	as.matrix(
		median_price.default(
			x = x,
			cols = cols,
			...
		)
	)
}
