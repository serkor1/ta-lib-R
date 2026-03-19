#' @export
#' @family Rolling Statistic
#'
#' @title Rolling Sum
#' @templateVar .title Rolling Sum
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun rolling_sum
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template rolling_description
#' @template rolling_returns
rolling_sum <- function(
	x,
	n = 10,
	na.ignore = FALSE
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
	n = 10,
	na.ignore = FALSE
) {
	## calculate indicator and
	## return as data.frame
	x <- .Call(
		"impl_ta_SUM",
		## splice:call:start
		as.double(x),
		as.integer(n),
		## splice:call:end
		as.logical(na.ignore)
	)

	## return indicator
	as.double(x)
}

#' @usage NULL
#' @aliases rolling_sum
#'
#' @export
rolling_sum.numeric <- function(
	x,
	n = 10,
	na.ignore = FALSE
) {
	## calculate indicator and
	## return as data.frame
	x <- rolling_sum.default(
		x = x,
		n = n,
		na.ignore = na.ignore
	)

	## return indicator
	as.double(x)
}
