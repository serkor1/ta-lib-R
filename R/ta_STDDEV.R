#' @export
#' @family Rolling Statistics
#'
#' @title Standard Deviation
#' @templateVar .title Standard Deviation
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun rolling_standard_deviation
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template rolling_description
#' @param deviations ([double]). Number of deviations. Defaults to `1`.
#' @template rolling_returns
rolling_standard_deviation <- function(
	x,
	timePeriod = 5,
	deviations = 1,
	na.bridge = FALSE,
	...
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
	timePeriod = 5,
	deviations = 1,
	na.bridge = FALSE,
	...
) {
	## calculate indicator and
	## return as data.frame
	x <- .Call(
		C_impl_ta_STDDEV,
		## splice:call:start
		as.double(x),
		as.integer(timePeriod),
		as.double(deviations),
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
#' @aliases rolling_standard_deviation
#'
#' @export
rolling_standard_deviation.numeric <- function(
	x,
	timePeriod = 5,
	deviations = 1,
	na.bridge = FALSE,
	...
) {
	## calculate indicator and
	## return as data.frame
	x <- rolling_standard_deviation.default(
		x = x,
		timePeriod = timePeriod,
		deviations = deviations,
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
STDDEV_lookback <- rolling_standard_deviation_lookback <- function(
	x,
	timePeriod = 5,
	deviations = 1,
	na.bridge = FALSE,
	...
) {
	.Call(
		C_impl_ta_STDDEV_lookback,
		as.integer(timePeriod),
		as.double(deviations)
	)
}
