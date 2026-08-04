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

#' @export
#' @usage NULL
#' @rdname rolling_beta
#'
#' @aliases rolling_beta
rollingBeta <- rolling_beta

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
	## rolling statistics are univariate -
	## multi-column input is rejected instead
	## of being flattened column-major
	assert(
		x = NCOL(x) == 1L,
		call = sys.call(sys.parent()),
		"Expected 'x' to be univariate.",
		paste0("Got ", NCOL(x), " columns.")
	)

	assert(
		x = NCOL(y) == 1L,
		call = sys.call(sys.parent()),
		"Expected 'y' to be univariate.",
		paste0("Got ", NCOL(y), " columns.")
	)

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
	class(x) <- NULL

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
#' @aliases rolling_beta
#'
#' @export
rolling_beta.xts <- function(
	x,
	y,
	timePeriod = 5,
	na.bridge = FALSE,
	...
) {
	assert_xts()

	## rolling statistics are univariate -
	## multi-column input is rejected instead
	## of being flattened column-major
	assert(
		x = NCOL(x) == 1L,
		call = sys.call(sys.parent()),
		"Expected 'x' to be univariate.",
		paste0("Got ", NCOL(x), " columns.")
	)

	assert(
		x = NCOL(y) == 1L,
		call = sys.call(sys.parent()),
		"Expected 'y' to be univariate.",
		paste0("Got ", NCOL(y), " columns.")
	)

	## extract the index
	## for later attachment
	x_names <- index(x)

	## calculate indicator and
	## return as <xts>
	x <- .Call(
		C_impl_ta_BETA,
		as.double(x),
		as.double(y),
		as.integer(timePeriod),
		as.logical(na.bridge)
	)

	## readd the index
	set_index(x, x_names)

	## return indicator
	as.xts(x)
}

#' @usage NULL
BETA_lookback <- rollingBeta_lookback <- rolling_beta_lookback <- function(
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
