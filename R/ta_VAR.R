#' @export
#' @family Rolling Statistic
#'
#' @title Rolling Standard Deviation
#' @templateVar .title Rolling Standard Deviation
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun rolling_variance
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
#' @template returns
rolling_variance <- function(
	x,
	n = 10,
	deviation = 1,
	...
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
	n = 10,
	deviation = 1,
	...
) {
	## calculate indicator and
	## return as data.frame
	x <- .Call(
		"impl_ta_VAR",
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
#' @aliases rolling_variance
#'
#' @export
rolling_variance.numeric <- function(
	x,
	n = 10,
	deviation = 1,
	...
) {
	## calculate indicator and
	## return as data.frame
	x <- rolling_variance.default(
		x = x,
		n = n,
		deviation = deviation,
		...
	)

	## return indicator
	as.double(x)
}
