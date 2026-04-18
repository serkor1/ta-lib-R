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
	n = 5,
	k = 1,
	na.bridge = FALSE
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
	n = 5,
	k = 1,
	na.bridge = FALSE
) {
	## calculate indicator and
	## return as data.frame
	x <- .Call(
		C_impl_ta_STDDEV,
		## splice:call:start
		as.double(x),
		as.integer(n),
		as.double(k),
		## splice:call:end
		as.logical(na.bridge)
	)

	## return indicator
	as.double(x)
}

#' @usage NULL
#' @aliases rolling_standard_deviation
#'
#' @export
rolling_standard_deviation.numeric <- function(
	x,
	n = 5,
	k = 1,
	na.bridge = FALSE
) {
	## calculate indicator and
	## return as data.frame
	x <- rolling_standard_deviation.default(
		x = x,
		n = n,
		k = k,
		na.bridge = na.bridge
	)

	## return indicator
	as.double(x)
}
