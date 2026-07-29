#' @export
#' @family Rolling Statistics
#'
#' @title Lowest value over a specified period
#' @templateVar .title Lowest value over a specified period
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun rolling_minimum
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template rolling_description
#'
#' @template rolling_returns
rolling_minimum <- function(
	x,
	timePeriod = 30,
	na.bridge = FALSE,
	...
) {
	UseMethod("rolling_minimum")
}

#' @export
#' @usage NULL
#' @rdname rolling_minimum
#'
#' @aliases rolling_minimum
MIN <- rolling_minimum

#' @usage NULL
#' @aliases rolling_minimum
#'
#' @export
rolling_minimum.default <- function(
	x,
	timePeriod = 30,
	na.bridge = FALSE,
	...
) {
	## calculate indicator and
	## return as data.frame
	x <- .Call(
		C_impl_ta_MIN,
		## splice:call:start
		as.double(x),
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
#' @aliases rolling_minimum
#'
#' @export
rolling_minimum.numeric <- function(
	x,
	timePeriod = 30,
	na.bridge = FALSE,
	...
) {
	## calculate indicator and
	## return as data.frame
	x <- rolling_minimum.default(
		x = x,
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

#' @usage NULL
MIN_lookback <- rolling_minimum_lookback <- function(
	x,
	timePeriod = 30,
	na.bridge = FALSE,
	...
) {
	.Call(
		C_impl_ta_MIN_lookback,
		as.integer(timePeriod)
	)
}
