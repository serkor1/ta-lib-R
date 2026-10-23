#' @export
#' @family Signals
#'
#' @title Cross Over
#'
#' @description
#' Identifies where `shortSeries` crosses `longSeries` from below, i.e.
#' where `shortSeries` was below `longSeries` on the previous bar and
#' is above it on the current bar. A typical use is a short moving
#' average crossing over a long moving average, or an oscillator
#' crossing over a threshold.
#'
#' Both comparisons are strict, so a series that only touches
#' `longSeries` is not a crossing.
#'
#' @param shortSeries An [integer] or [double] vector.
#' @param longSeries An [integer] or [double] vector of the same [length] as `shortSeries`, or of [length] 1 to compare against a fixed level.
#' @param na.rm A [logical] of [length] 1. If `TRUE`, a crossing that involves a missing value on either bar is returned as [NA]. If `FALSE` (default), missing values are not checked and such bars are returned as `0`.
#'
#' @examples
#' ## short moving average crossing
#' ## over a long moving average
#' talib::cross_over(
#' 	talib::SMA(talib::BTC$close, timePeriod = 10),
#' 	talib::SMA(talib::BTC$close, timePeriod = 30)
#' )
#'
#' ## RSI crossing over 30
#' talib::cross_over(
#' 	talib::RSI(talib::BTC$close),
#' 	30
#' )
#'
#' @concept finance
#' @concept technical analysis
#' @concept trading
#' @concept algorithmic trading
#'
#' @author Serkan Korkmaz
#'
#' @returns
#' An [integer] vector of the same [length] as `shortSeries` with `1` where `shortSeries` crosses over `longSeries` and `0` otherwise.
#' The first element is always [NA] as it has no previous bar.
cross_over <- function(
	shortSeries,
	longSeries,
	na.rm = FALSE
) {
	UseMethod("cross_over")
}

#' @export
#' @usage NULL
#' @rdname cross_over
crossOver <- cross_over

#' @export
cross_over.integer <- function(
	shortSeries,
	longSeries,
	na.rm = FALSE
) {
	## set longSeries to the same
	## length of the shortSeries with
	## the same value to enable comparisions
	## of length 1.
	## 	This is relevant for, say, comparisions
	##  of RSI against some threshold value
	if (length(longSeries) == 1L) {
		longSeries <- rep(
			x = longSeries,
			times = length(shortSeries)
		)
	}

	## assert that the lenght of both series
	## are equal
	assert(
		x = length(shortSeries) == length(longSeries),
		call = sys.call(sys.parent()),
		"Expected 'shortSeries' and 'longSeries' to be of same length or 'longSeries' to be length 1.",
		paste0("'shortSeries' is ", length(shortSeries), " rows."),
		paste0("'longSeries' is ", length(longSeries), " rows.")
	)

	.Call(
		talib:::C_impl_simple_crossing,
		shortSeries,
		longSeries,
		na.rm,
		1L
	)
}

#' @export
cross_over.double <- function(
	shortSeries,
	longSeries,
	na.rm = FALSE
) {
	## set longSeries to the same
	## length of the shortSeries with
	## the same value to enable comparisions
	## of length 1.
	## 	This is relevant for, say, comparisions
	##  of RSI against some threshold value
	if (length(longSeries) == 1L) {
		longSeries <- rep(
			x = longSeries,
			times = length(shortSeries)
		)
	}

	## assert that the lenght of both series
	## are equal
	assert(
		x = length(shortSeries) == length(longSeries),
		call = sys.call(sys.parent()),
		"Expected 'shortSeries' and 'longSeries' to be of same length or 'longSeries' to be length 1.",
		paste0("'shortSeries' is ", length(shortSeries), " rows."),
		paste0("'longSeries' is ", length(longSeries), " rows.")
	)

	.Call(
		talib:::C_impl_simple_crossing,
		shortSeries,
		longSeries,
		na.rm,
		1L
	)
}

#'@export
#' @family Signals
#'
#' @title Cross Under
#'
#' @description
#' Identifies where `shortSeries` crosses `longSeries` from above, i.e.
#' where `shortSeries` was above `longSeries` on the previous bar and
#' is below it on the current bar. A cross under is a bearish signal and
#' is emitted as `-1`, consistent with bearish candlestick patterns.
#'
#' Both comparisons are strict, so a series that only touches
#' `longSeries` is not a crossing.
#'
#' @inheritParams cross_over
#'
#' @examples
#' ## short moving average crossing
#' ## under a long moving average
#' talib::cross_under(
#' 	talib::SMA(talib::BTC$close, timePeriod = 10),
#' 	talib::SMA(talib::BTC$close, timePeriod = 30)
#' )
#'
#' ## RSI crossing under 70
#' talib::cross_under(
#' 	talib::RSI(talib::BTC$close),
#' 	70
#' )
#'
#' @concept finance
#' @concept technical analysis
#' @concept trading
#' @concept algorithmic trading
#'
#' @author Serkan Korkmaz
#'
#' @returns
#' An [integer] vector of the same [length] as `shortSeries` with `-1` where `shortSeries` crosses under `longSeries` and `0` otherwise.
#' The first element is always [NA] as it has no previous bar.
cross_under <- function(
	shortSeries,
	longSeries,
	na.rm = FALSE
) {
	UseMethod("cross_under")
}

#' @export
#' @usage NULL
#' @rdname cross_under
crossUnder <- cross_under

#' @export
cross_under.integer <- function(
	shortSeries,
	longSeries,
	na.rm = FALSE
) {
	## set longSeries to the same
	## length of the shortSeries with
	## the same value to enable comparisions
	## of length 1.
	## 	This is relevant for, say, comparisions
	##  of RSI against some threshold value
	if (length(longSeries) == 1L) {
		longSeries <- rep(
			x = longSeries,
			times = length(shortSeries)
		)
	}

	## assert that the lenght of both series
	## are equal
	assert(
		x = length(shortSeries) == length(longSeries),
		call = sys.call(sys.parent()),
		"Expected 'shortSeries' and 'longSeries' to be of same length or 'longSeries' to be length 1.",
		paste0("'shortSeries' is ", length(shortSeries), " rows."),
		paste0("'longSeries' is ", length(longSeries), " rows.")
	)

	.Call(
		talib:::C_impl_simple_crossing,
		shortSeries,
		longSeries,
		na.rm,
		-1L
	)
}

#' @export
cross_under.double <- function(
	shortSeries,
	longSeries,
	na.rm = FALSE
) {
	## set longSeries to the same
	## length of the shortSeries with
	## the same value to enable comparisions
	## of length 1.
	## 	This is relevant for, say, comparisions
	##  of RSI against some threshold value
	if (length(longSeries) == 1L) {
		longSeries <- rep(
			x = longSeries,
			times = length(shortSeries)
		)
	}

	## assert that the lenght of both series
	## are equal
	assert(
		x = length(shortSeries) == length(longSeries),
		call = sys.call(sys.parent()),
		"Expected 'shortSeries' and 'longSeries' to be of same length or 'longSeries' to be length 1.",
		paste0("'shortSeries' is ", length(shortSeries), " rows."),
		paste0("'longSeries' is ", length(longSeries), " rows.")
	)

	.Call(
		talib:::C_impl_simple_crossing,
		shortSeries,
		longSeries,
		na.rm,
		-1L
	)
}

#'@export
#' @family Signals
#'
#' @title Cross Series
#'
#' @description
#' Identifies where `shortSeries` crosses `longSeries` in either
#' direction. A cross over is emitted as `1` and a cross under as `-1`,
#' so the result equals the sum of [cross_over()] and [cross_under()].
#'
#' Both comparisons are strict, so a series that only touches
#' `longSeries` is not a crossing.
#'
#' @inheritParams cross_over
#'
#' @examples
#' ## short moving average crossing
#' ## a long moving average
#' talib::cross_series(
#' 	talib::SMA(talib::BTC$close, timePeriod = 10),
#' 	talib::SMA(talib::BTC$close, timePeriod = 30)
#' )
#'
#' @concept finance
#' @concept technical analysis
#' @concept trading
#' @concept algorithmic trading
#'
#' @author Serkan Korkmaz
#'
#' @returns
#' An [integer] vector of the same [length] as `shortSeries` with `1` where `shortSeries` crosses over `longSeries`, `-1` where it crosses under and `0` otherwise.
#' The first element is always [NA] as it has no previous bar.
cross_series <- function(
	shortSeries,
	longSeries,
	na.rm = FALSE
) {
	UseMethod("cross_series")
}

#' @export
#' @usage NULL
#' @rdname cross_series
crossSeries <- cross_series

#' @export
cross_series.integer <- function(
	shortSeries,
	longSeries,
	na.rm = FALSE
) {
	## set longSeries to the same
	## length of the shortSeries with
	## the same value to enable comparisions
	## of length 1.
	## 	This is relevant for, say, comparisions
	##  of RSI against some threshold value
	if (length(longSeries) == 1L) {
		longSeries <- rep(
			x = longSeries,
			times = length(shortSeries)
		)
	}

	## assert that the lenght of both series
	## are equal
	assert(
		x = length(shortSeries) == length(longSeries),
		call = sys.call(sys.parent()),
		"Expected 'shortSeries' and 'longSeries' to be of same length or 'longSeries' to be length 1.",
		paste0("'shortSeries' is ", length(shortSeries), " rows."),
		paste0("'longSeries' is ", length(longSeries), " rows.")
	)

	.Call(
		talib:::C_impl_simple_crossing,
		shortSeries,
		longSeries,
		na.rm,
		0L
	)
}

#' @export
cross_series.double <- function(
	shortSeries,
	longSeries,
	na.rm = FALSE
) {
	## set longSeries to the same
	## length of the shortSeries with
	## the same value to enable comparisions
	## of length 1.
	## 	This is relevant for, say, comparisions
	##  of RSI against some threshold value
	if (length(longSeries) == 1L) {
		longSeries <- rep(
			x = longSeries,
			times = length(shortSeries)
		)
	}

	## assert that the lenght of both series
	## are equal
	assert(
		x = length(shortSeries) == length(longSeries),
		call = sys.call(sys.parent()),
		"Expected 'shortSeries' and 'longSeries' to be of same length or 'longSeries' to be length 1.",
		paste0("'shortSeries' is ", length(shortSeries), " rows."),
		paste0("'longSeries' is ", length(longSeries), " rows.")
	)

	.Call(
		talib:::C_impl_simple_crossing,
		shortSeries,
		longSeries,
		na.rm,
		0L
	)
}
