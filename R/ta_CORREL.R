#' @export
#' @family Statistic Functions
#'
#' @title Pearson&apos;s Correlation Coefficient (r)
#' @templateVar .title Pearson&apos;s Correlation Coefficient (r)
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun rolling_correlation
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template rolling_description
#'
#' @template rolling_returns
rolling_correlation <- function(
	x,
	y,
	timePeriod = 30,
	na.bridge = FALSE
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
	timePeriod = 30,
	na.bridge = FALSE
) {
	## calculate indicator and
	## return as data.frame
	x <- .Call(
		C_impl_ta_CORREL,
		## splice:call:start
		as.double(x),
		as.double(y),
		as.integer(timePeriod),
		## splice:call:end
		as.logical(na.bridge)
	)

	## strip dimensions
	## while preserving
	## attributes
	dim(x) <- NULL

	## return indicator
	x
}

#' @usage NULL
#' @aliases rolling_correlation
#'
#' @export
rolling_correlation.numeric <- function(
	x,
	y,
	timePeriod = 30,
	na.bridge = FALSE
) {
	## calculate indicator and
	## return as data.frame
	x <- rolling_correlation.default(
		x = x,
		y = y,
		timePeriod = timePeriod,
		na.bridge = na.bridge
	)

	## strip dimensions
	## while preserving
	## attributes
	dim(x) <- NULL

	## return indicator
	x
}
