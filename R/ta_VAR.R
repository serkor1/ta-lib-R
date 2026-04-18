#' @export
#' @family Rolling Statistic
#'
#' @title Rolling Standard Deviation
#' @templateVar .title Rolling Standard Deviation
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun rolling_variance
#'
## splice:documentation:start
#' @param k multiplier
## splice:documentation:end
#'
#' @template rolling_description
#' @template rolling_returns
rolling_variance <- function(
	x,
	n = 5,
	k = 1,
	na.bridge = FALSE
) {
	UseMethod("rolling_variance")
}

#' @export
#' @usage NULL
#' @rdname rolling_variance
#'
#' @aliases rolling_variance
VAR <- rolling_variance

#' @usage NULL
#' @aliases rolling_variance
#'
#' @export
rolling_variance.default <- function(
	x,
	n = 5,
	k = 1,
	na.bridge = FALSE
) {
	## calculate indicator and
	## return as data.frame
	x <- .Call(
		C_impl_ta_VAR,
		## splice:call:start
		as.double(x),
		as.integer(n),
		as.double(k),
		## splice:call:end
		as.logical(na.bridge)
	)

	## return indicator
	as.double(x)
}

#' @usage NULL
#' @aliases rolling_variance
#'
#' @export
rolling_variance.numeric <- function(
	x,
	n = 5,
	k = 1,
	na.bridge = FALSE
) {
	## calculate indicator and
	## return as data.frame
	x <- rolling_variance.default(
		x = x,
		n = n,
		k = k,
		na.bridge = na.bridge
	)

	## return indicator
	as.double(x)
}
