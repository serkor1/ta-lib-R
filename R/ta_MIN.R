#' @export
#' @family Rolling Statistic
#'
#' @title Rolling Min
#' @templateVar .title Rolling Min
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun rolling_min
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template rolling_description
#' @template rolling_returns
rolling_min <- function(
	x,
	n = 30,
	na.bridge = FALSE
) {
	UseMethod("rolling_min")
}

#' @export
#' @usage NULL
#' @rdname rolling_min
#'
#' @aliases rolling_min
MIN <- rolling_min

#' @usage NULL
#' @aliases rolling_min
#'
#' @export
rolling_min.default <- function(
	x,
	n = 30,
	na.bridge = FALSE
) {
	## calculate indicator and
	## return as data.frame
	x <- .Call(
		C_impl_ta_MIN,
		## splice:call:start
		as.double(x),
		as.integer(n),
		## splice:call:end
		as.logical(na.bridge)
	)

	## return indicator
	as.double(x)
}

#' @usage NULL
#' @aliases rolling_min
#'
#' @export
rolling_min.numeric <- function(
	x,
	n = 30,
	na.bridge = FALSE
) {
	## calculate indicator and
	## return as data.frame
	x <- rolling_min.default(
		x = x,
		n = n,
		na.bridge = na.bridge
	)

	## return indicator
	as.double(x)
}
