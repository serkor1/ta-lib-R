#' @export
#' @family Rolling Statistics
#'
#' @title Highest value over a specified period
#' @templateVar .title Highest value over a specified period
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun rolling_maximum
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template rolling_description
#'
#' @template rolling_returns
rolling_maximum <- function(
	x,
	timePeriod = 30,
	na.bridge = FALSE
) {
	UseMethod("rolling_maximum")
}

#' @export
#' @usage NULL
#' @rdname rolling_maximum
#'
#' @aliases rolling_maximum
MAX <- rolling_maximum

#' @usage NULL
#' @aliases rolling_maximum
#'
#' @export
rolling_maximum.default <- function(
	x,
	timePeriod = 30,
	na.bridge = FALSE
) {
	## calculate indicator and
	## return as data.frame
	x <- .Call(
		C_impl_ta_MAX,
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
#' @aliases rolling_maximum
#'
#' @export
rolling_maximum.numeric <- function(
	x,
	timePeriod = 30,
	na.bridge = FALSE
) {
	## calculate indicator and
	## return as data.frame
	x <- rolling_maximum.default(
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
