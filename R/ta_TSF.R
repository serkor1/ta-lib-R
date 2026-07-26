#' @export
#' @family Statistic Functions
#'
#' @title Time Series Forecast
#' @templateVar .title Time Series Forecast
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun TSF
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template rolling_description
#' @template rolling_returns
TSF <- function(
	x,
	timePeriod = 14,
	na.bridge = FALSE
) {
	UseMethod("TSF")
}

#' @export
#' @usage NULL
#' @rdname TSF
#'
#' @aliases TSF
TSF <- TSF

#' @usage NULL
#' @aliases TSF
#'
#' @export
TSF.default <- function(
	x,
	timePeriod = 14,
	na.bridge = FALSE
) {
	## calculate indicator and
	## return as data.frame
	x <- .Call(
		C_impl_ta_TSF,
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
#' @aliases TSF
#'
#' @export
TSF.numeric <- function(
	x,
	timePeriod = 14,
	na.bridge = FALSE
) {
	## calculate indicator and
	## return as data.frame
	x <- TSF.default(
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
