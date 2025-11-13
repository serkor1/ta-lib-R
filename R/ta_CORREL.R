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
	n = 10
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
	n = 10
) {
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
	as.double(x)
}

#' @usage NULL
#' @aliases rolling_correlation
#'
#' @export
rolling_correlation.numeric <- function(
	x,
	y,
	n = 10
) {
	## calculate indicator and
	## return as data.frame
	x <- rolling_correlation.default(
		x = x,
		y = y,
		n = n
	)

	## return indicator
	as.double(x)
}
