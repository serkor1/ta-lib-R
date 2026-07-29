#' @export
#' @family Rolling Statistics
#'
#' @title Beta
#' @templateVar .title Beta
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun rolling_beta
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template rolling_description
#'
#' @template rolling_returns
rolling_beta <- function(
	x,
	y,
	timePeriod = 5,
	na.bridge = FALSE,
	...
) {
	UseMethod("rolling_beta")
}

#' @export
#' @usage NULL
#' @rdname rolling_beta
#'
#' @aliases rolling_beta
BETA <- rolling_beta

#' @usage NULL
#' @aliases rolling_beta
#'
#' @export
rolling_beta.default <- function(
	x,
	y,
	timePeriod = 5,
	na.bridge = FALSE,
	...
) {
	## calculate indicator and
	## return as data.frame
	x <- .Call(
		C_impl_ta_BETA,
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
#' @aliases rolling_beta
#'
#' @export
rolling_beta.numeric <- function(
	x,
	y,
	timePeriod = 5,
	na.bridge = FALSE,
	...
) {
	## calculate indicator and
	## return as data.frame
	x <- rolling_beta.default(
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

#' @usage NULL
BETA_lookback <- rolling_beta_lookback <- function(
	x,
	timePeriod = 5,
	na.bridge = FALSE,
	...
) {
	.Call(
		C_impl_ta_BETA_lookback,
		as.integer(timePeriod)
	)
}
