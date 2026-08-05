#' @export
#' @family Rolling Statistics
#'
#' @title Variance
#' @templateVar .title Variance
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun rolling_variance
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template rolling_description
#' @param deviations ([double]). Number of deviations. Defaults to `1`.
#' @template rolling_returns
rolling_variance <- function(
	x,
	timePeriod = 5,
	deviations = 1,
	na.bridge = FALSE,
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

#' @export
#' @usage NULL
#' @rdname rolling_variance
#'
#' @aliases rolling_variance
rollingVariance <- rolling_variance

#' @usage NULL
#' @aliases rolling_variance
#'
#' @export
rolling_variance.default <- function(
	x,
	timePeriod = 5,
	deviations = 1,
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

	## calculate indicator and
	## return as data.frame
	x <- .Call(
		C_impl_ta_VAR,
		## splice:call:start
		as.double(x),
		as.integer(timePeriod),
		as.double(deviations),
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
#' @aliases rolling_variance
#'
#' @export
rolling_variance.numeric <- function(
	x,
	timePeriod = 5,
	deviations = 1,
	na.bridge = FALSE,
	...
) {
	## calculate indicator and
	## return as data.frame
	x <- rolling_variance.default(
		x = x,
		timePeriod = timePeriod,
		deviations = deviations,
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
#' @aliases rolling_variance
#'
#' @export
rolling_variance.xts <- function(
	x,
	timePeriod = 5,
	deviations = 1,
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

	## extract the index
	## for later attachment
	x_names <- index(x)

	## calculate indicator and
	## return as <xts>
	x <- .Call(
		C_impl_ta_VAR,
		as.double(x),
		as.integer(timePeriod),
		as.double(deviations),
		as.logical(na.bridge)
	)

	## readd the index
	set_index(x, x_names)

	## return indicator
	as.xts(x)
}

#' @usage NULL
VAR_lookback <- rollingVariance_lookback <- rolling_variance_lookback <- function(
	x,
	timePeriod = 5,
	deviations = 1,
	na.bridge = FALSE,
	...
) {
	.Call(
		C_impl_ta_VAR_lookback,
		as.integer(timePeriod),
		as.double(deviations)
	)
}
