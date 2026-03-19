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
#' @template returns
typical_price <- function(
	x,
	cols,
	na.rm = FALSE,
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

#' @usage NULL
#' @aliases typical_price
#'
#' @export
typical_price.default <- function(
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
		"impl_ta_TYPPRICE",
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
#' @aliases typical_price
#'
#' @export
typical_price.data.frame <- function(
	x,
	cols,
	na.rm = FALSE,
	...
) {
	map_dfr(
		typical_price.default(
			x = x,
			cols = cols,
			na.rm = na.rm,
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
	na.rm = FALSE,
	...
) {
	typical_price.default(
		x = x,
		cols = cols,
		na.rm = na.rm,
		...
	)
}
