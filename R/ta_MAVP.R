#' @export
#' @family Overlap Studies
#'
#' @title Moving average with variable period
#' @templateVar .title Moving average with variable period
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun variable_moving_average_period
#' @templateVar .family Overlap Studies
#' @templateVar .formula ~close + periods
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
#' @param minimumPeriod ([integer]). Value less than minimum will be changed to Minimum period. Defaults to `2`.
#' @param maximumPeriod ([integer]). Value higher than maximum will be changed to Maximum period. Defaults to `30`.
#' @param maType ([integer]). Type of Moving Average. Defaults to `0` ([SMA]). Can also be passed as talib::SMA.
#' @template returns
variable_moving_average_period <- function(
	x,
	cols,
	minimumPeriod = 2,
	maximumPeriod = 30,
	maType = 0,
	na.bridge = FALSE,
	...
) {
	UseMethod("variable_moving_average_period")
}

#' @export
#' @usage NULL
#' @rdname variable_moving_average_period
#'
#' @aliases variable_moving_average_period
MAVP <- variable_moving_average_period

#' @usage NULL
#' @aliases variable_moving_average_period
#'
#' @export
variable_moving_average_period.default <- function(
	x,
	cols,
	minimumPeriod = 2,
	maximumPeriod = 30,
	maType = 0,
	na.bridge = FALSE,
	...
) {
	## validate 'cols'-argument
	## if explicitly passed
	if (!missing(cols)) {
		assert_formula(cols)
	}

	## construct series
	## from input
	constructed_series <- series(
		x = cols,
		default_formula = ~ close + periods,
		data = x,
		...
	)

	## extract rownames
	## for later attachment
	x_names <- rownames(constructed_series)

	## calculate indicator and
	## return as data.frame
	x <- .Call(
		C_impl_ta_MAVP,
		constructed_series[[1]],
		constructed_series[[2]],
		as.integer(minimumPeriod),
		as.integer(maximumPeriod),
		as.integer(maType),
		as.logical(na.bridge)
	)

	## readd rownames
	set_rownames(x, x_names)

	## return indicator
	x
}

#' @usage NULL
#' @aliases variable_moving_average_period
#'
#' @export
variable_moving_average_period.data.frame <- function(
	x,
	cols,
	minimumPeriod = 2,
	maximumPeriod = 30,
	maType = 0,
	na.bridge = FALSE,
	...
) {
	map_dfr(
		variable_moving_average_period.default(
			x = x,
			cols = cols,
			minimumPeriod = minimumPeriod,
			maximumPeriod = maximumPeriod,
			maType = maType,
			na.bridge = na.bridge,
			...
		)
	)
}

#' @usage NULL
#' @aliases variable_moving_average_period
#'
#' @export
variable_moving_average_period.matrix <- function(
	x,
	cols,
	minimumPeriod = 2,
	maximumPeriod = 30,
	maType = 0,
	na.bridge = FALSE,
	...
) {
	variable_moving_average_period.default(
		x = x,
		cols = cols,
		minimumPeriod = minimumPeriod,
		maximumPeriod = maximumPeriod,
		maType = maType,
		na.bridge = na.bridge,
		...
	)
}

#' @usage NULL
variable_moving_average_period_lookback <- function(
	x,
	cols,
	minimumPeriod = 2,
	maximumPeriod = 30,
	maType = 0,
	na.bridge = FALSE,
	...
) {
	.Call(
		C_impl_ta_MAVP_lookback,
		as.integer(minimumPeriod),
		as.integer(maximumPeriod),
		as.integer(maType)
	)
}
