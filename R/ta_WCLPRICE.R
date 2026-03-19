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
#' @template returns
weighted_close_price <- function(
	x,
	cols,
	na.rm = FALSE,
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
	na.rm = FALSE,
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

	## handle missing values
	if (na.rm) {
		na_info <- strip_na(constructed_series, x_names)
		constructed_series <- na_info$series
		x_names <- na_info$x_names
	}

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

	## re-expand NA rows
	if (na.rm && !is.null(na_info$na_idx)) {
		x <- reexpand_na(x, na_info)
		x_names <- na_info$x_names_all
	}

	## readd rownames
	set_rownames(x, x_names)

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
	na.rm = FALSE,
	...
) {
	map_dfr(
		weighted_close_price.default(
			x = x,
			cols = cols,
			na.rm = na.rm,
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
	na.rm = FALSE,
	...
) {
	weighted_close_price.default(
		x = x,
		cols = cols,
		na.rm = na.rm,
		...
	)
}
