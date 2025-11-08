#' @export
#' @family Price Transform
#'
#' @title Weighted Close Price
#' @templateVar .title Weighted Close Price
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun weighted_close_price
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
#' @template returns
weighted_close_price <- function(
	x,
	cols,
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

#' @usage NULL
#' @aliases weighted_close_price
#'
#' @export
weighted_close_price.default <- function(
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
		"impl_ta_WCLPRICE",
		## splice:call:start
		constructed_series[[1]],
		constructed_series[[2]],
		constructed_series[[3]]
		## splice:call:end
	)

	## readd rownames
	rownames(x) <- x_names

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
	...
) {
	as.data.frame(
		weighted_close_price.default(
			x = x,
			cols = cols,
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
	...
) {
	as.matrix(
		weighted_close_price.default(
			x = x,
			cols = cols,
			...
		)
	)
}
