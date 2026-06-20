#' @export
#' @family Rolling Statistic
#'
#' @title Rolling Max
#' @templateVar .title Rolling Max
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun rolling_max
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template rolling_description
#' @template rolling_returns
rolling_max <- function(
	x,
	n = 30,
	na.bridge = FALSE
) {
	UseMethod("rolling_max")
}

#' @export
#' @usage NULL
#' @rdname rolling_max
#'
#' @aliases rolling_max
MAX <- rolling_max

#' @usage NULL
#' @aliases rolling_max
#'
#' @export
rolling_max.default <- function(
	x,
	n = 30,
	na.bridge = FALSE
) {
	## calculate indicator and
	## return as data.frame
	x <- .Call(
		C_impl_ta_MAX,
		## splice:call:start
		as.double(x),
		as.integer(n),
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
#' @aliases rolling_max
#'
#' @export
rolling_max.numeric <- function(
	x,
	n = 30,
	na.bridge = FALSE
) {
	## calculate indicator and
	## return as data.frame
	x <- rolling_max.default(
		x = x,
		n = n,
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
MAX_lookback <- rolling_max_lookback <- function(
	x,
	n = 30
) {
	.Call(
		C_impl_ta_MAX_lookback,
		## splice:lookback:start
		as.double(x),
		as.integer(n)
		## splice:lookback:end
	)
}
