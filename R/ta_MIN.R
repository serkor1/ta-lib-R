#' @export
#' @family Rolling Satistics
#'
#' @title Lowest value over a specified period
#' @templateVar .title Lowest value over a specified period
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun rolling_mininimum
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template rolling_description
#'
#' @template rolling_returns
rolling_mininimum <- function(
	x,
	timePeriod = 30,
	na.bridge = FALSE
) {
	UseMethod("rolling_mininimum")
}

#' @export
#' @usage NULL
#' @rdname rolling_mininimum
#'
#' @aliases rolling_mininimum
MIN <- rolling_mininimum

#' @usage NULL
#' @aliases rolling_mininimum
#'
#' @export
rolling_mininimum.default <- function(
	x,
	timePeriod = 30,
	na.bridge = FALSE
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
#' @aliases rolling_mininimum
#'
#' @export
rolling_mininimum.numeric <- function(
	x,
	timePeriod = 30,
	na.bridge = FALSE
) {
	## calculate indicator and
	## return as data.frame
	x <- rolling_mininimum.default(
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
