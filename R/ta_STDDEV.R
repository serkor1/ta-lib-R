#' @export
#' @family Rolling Statistic
#'
#' @title Rolling Standard Deviation
#' @templateVar .title Rolling Standard Deviation
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun rolling_standard_deviation
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
#' @template returns
rolling_standard_deviation <- function(
	x,
	n = 10,
	deviation = 1,
	...
) {
	UseMethod("rolling_standard_deviation")
}

#' @export
#' @usage NULL
#' @rdname rolling_standard_deviation
#'
#' @aliases rolling_standard_deviation
STDDEV <- rolling_standard_deviation

#' @usage NULL
#' @aliases rolling_standard_deviation
#'
#' @export
rolling_standard_deviation.default <- function(
	x,
	n = 10,
	deviation = 1,
	...
) {
	## calculate indicator and
	## return as data.frame
	x <- .Call(
		"impl_ta_STDDEV",
		## splice:call:start
		as.double(x),
		as.integer(n),
		as.double(deviation)
		## splice:call:end
	)

	## return indicator
	as.double(x)
}

#' @usage NULL
#' @aliases rolling_standard_deviation
#'
#' @export
rolling_standard_deviation.numeric <- function(
	x,
	n = 10,
	deviation = 1,
	...
) {
	## calculate indicator and
	## return as data.frame
	x <- rolling_standard_deviation.default(
		x = x,
		n = n,
		deviation = deviation,
		...
	)

	## return indicator
	as.double(x)
}
