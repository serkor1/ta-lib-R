#' @export
#' @family Rolling Statistic
#'
#' @title Rolling Min
#' @templateVar .title Rolling Min
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun rolling_min
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template rolling_description
#' @template rolling_returns
rolling_min <- function(
	x,
	n = 10,
	na.rm = FALSE
) {
	UseMethod("rolling_min")
}

#' @export
#' @usage NULL
#' @rdname rolling_min
#'
#' @aliases rolling_min
MIN <- rolling_min

#' @usage NULL
#' @aliases rolling_min
#'
#' @export
rolling_min.default <- function(
	x,
	n = 10,
	na.rm = FALSE
) {
	## handle missing values
	if (na.rm) {
		na_info <- strip_na_vector(x)
		x <- na_info$x
	}

	## calculate indicator and
	## return as data.frame
	x <- .Call(
		"impl_ta_MIN",
		## splice:call:start
		as.double(x),
		as.integer(n)
		## splice:call:end
	)

	## return indicator
	x <- as.double(x)

	## re-expand NA positions
	if (na.rm && !is.null(na_info$na_idx)) {
		x <- reexpand_na_vector(x, na_info)
	}

	x
}

#' @usage NULL
#' @aliases rolling_min
#'
#' @export
rolling_min.numeric <- function(
	x,
	n = 10,
	na.rm = FALSE
) {
	## calculate indicator and
	## return as data.frame
	x <- rolling_min.default(
		x = x,
		n = n,
		na.rm = na.rm
	)

	## return indicator
	as.double(x)
}
