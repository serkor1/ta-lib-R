#' @export
#' @family Rolling Statistic
#'
#' @title Rolling Standard Deviation
#' @templateVar .title Rolling Standard Deviation
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun rolling_standard_deviation
#'
## splice:documentation:start
#' @param k ([double]). Multiplier for the standard deviation.
## splice:documentation:end
#'
#' @template rolling_description
#' @template rolling_returns
rolling_standard_deviation <- function(
	x,
	n = 10,
	k = 1,
	na.rm = FALSE
) {
	UseMethod("rolling_standard_deviation")
}

#' @export
#' @usage NULL
#' @rdname rolling_standard_deviation
#'
#' @aliases rolling_standard_deviation
STDDEV <- rolling_standard_deviation

#' @usage NULL
#' @aliases rolling_standard_deviation
#'
#' @export
rolling_standard_deviation.default <- function(
	x,
	n = 10,
	k = 1,
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
		"impl_ta_STDDEV",
		## splice:call:start
		as.double(x),
		as.integer(n),
		as.double(k)
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
#' @aliases rolling_standard_deviation
#'
#' @export
rolling_standard_deviation.numeric <- function(
	x,
	n = 10,
	k = 1,
	na.rm = FALSE
) {
	## calculate indicator and
	## return as data.frame
	x <- rolling_standard_deviation.default(
		x = x,
		n = n,
		k = k,
		na.rm = na.rm
	)

	## return indicator
	as.double(x)
}
