#' @export
#' @family Rolling Statistics
#'
#' @title Summation
#' @templateVar .title Summation
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun rolling_sum
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template rolling_description
#'
#' @template rolling_returns
rolling_sum <- function(
	x,
	timePeriod = 30,
	na.bridge = FALSE,
	...
) {
	UseMethod("rolling_sum")
}

#' @export
#' @usage NULL
#' @rdname rolling_sum
#'
#' @aliases rolling_sum
SUM <- rolling_sum

#' @usage NULL
#' @aliases rolling_sum
#'
#' @export
rolling_sum.default <- function(
	x,
	timePeriod = 30,
	na.bridge = FALSE,
	...
) {
	## calculate indicator and
	## return as data.frame
	x <- .Call(
		C_impl_ta_SUM,
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
#' @aliases rolling_sum
#'
#' @export
rolling_sum.numeric <- function(
	x,
	timePeriod = 30,
	na.bridge = FALSE,
	...
) {
	## calculate indicator and
	## return as data.frame
	x <- rolling_sum.default(
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
SUM_lookback <- rolling_sum_lookback <- function(
	x,
	timePeriod = 30,
	na.bridge = FALSE,
	...
) {
	.Call(
		C_impl_ta_SUM_lookback,
		as.integer(timePeriod)
	)
}
