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
#' @template description
#' @template returns
rolling_max <- function(
	x,
	n = 10,
	...
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
	n = 10,
	...
) {
	## calculate indicator and
	## return as data.frame
	x <- .Call(
		"impl_ta_MAX",
		## splice:call:start
		as.double(x),
		as.integer(n)
		## splice:call:end
	)

	## return indicator
	as.double(x)
}

#' @usage NULL
#' @aliases rolling_max
#'
#' @export
rolling_max.numeric <- function(
	x,
	n = 10,
	...
) {
	## calculate indicator and
	## return as data.frame
	x <- rolling_max.default(
		x = x,
		n = n,
		...
	)

	## return indicator
	as.double(x)
}
