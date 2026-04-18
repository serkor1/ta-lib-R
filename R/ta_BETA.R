#' @export
#' @family Rolling Statistic
#'
#' @title Rolling Beta
#' @templateVar .title Rolling Beta
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun rolling_beta
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template rolling_description
#' @template rolling_returns
rolling_beta <- function(
	x,
	y,
	n = 10,
	na.ignore = FALSE
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
	n = 10,
	na.ignore = FALSE
) {
	## calculate indicator and
	## return as data.frame
	x <- .Call(
		C_impl_ta_BETA,
		## splice:call:start
		as.double(x),
		as.double(y),
		as.integer(n),
		## splice:call:end
		as.logical(na.ignore)
	)

	## return indicator
	as.double(x)
}

#' @usage NULL
#' @aliases rolling_beta
#'
#' @export
rolling_beta.numeric <- function(
	x,
	y,
	n = 10,
	na.ignore = FALSE
) {
	## calculate indicator and
	## return as data.frame
	x <- rolling_beta.default(
		x = x,
		y = y,
		n = n,
		na.ignore = na.ignore
	)

	## return indicator
	as.double(x)
}
