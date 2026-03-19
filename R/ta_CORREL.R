#' @export
#' @family Rolling Statistic
#'
#' @title Rolling Correlation
#' @templateVar .title Rolling Correlation
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun rolling_correlation
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template rolling_description
#' @template rolling_returns
rolling_correlation <- function(
	x,
	y,
	n = 10,
	na.rm = FALSE
) {
	UseMethod("rolling_correlation")
}

#' @export
#' @usage NULL
#' @rdname rolling_correlation
#'
#' @aliases rolling_correlation
CORREL <- rolling_correlation

#' @usage NULL
#' @aliases rolling_correlation
#'
#' @export
rolling_correlation.default <- function(
	x,
	y,
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
		"impl_ta_CORREL",
		## splice:call:start
		as.double(x),
		as.double(y),
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
#' @aliases rolling_correlation
#'
#' @export
rolling_correlation.numeric <- function(
	x,
	y,
	n = 10,
	na.rm = FALSE
) {
	## calculate indicator and
	## return as data.frame
	x <- rolling_correlation.default(
		x = x,
		y = y,
		n = n,
		na.rm = na.rm
	)

	## return indicator
	as.double(x)
}
