#' @export
#' @family Momentum Indicator
#'
#' @title Moving Average Convergence Divergence
#'
#' @templateVar .title Bollinger Bands
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun moving_average_convergence_divergence
#'
#' @param fast Number of period for the fast MA.
#' @param slow Number of period for the slow MA.
#' @param signal Smoothing for the signal line.
#'
#' @template description
#'
#' @returns
#' A [data.frame]- or [matrix]-object with the format:
#'
#' \describe{
#'  \item{macd <[double]>}{The lower band.}
#'  \item{signal <[double]>}{The middle band.}
#'  \item{histogram <[double]>}{The upper band.}
#' }
#'
#' @export
moving_average_convergence_divergence <- function(
	x,
	cols,
	fast = 12,
	slow = 26,
	signal = 9,
	...
) {
	UseMethod("moving_average_convergence_divergence")
}

#' @export
#'
#' @usage NULL
#'
#' @rdname moving_average_convergence_divergence
#' @aliases moving_average_convergence_divergence
MACD <- moving_average_convergence_divergence

#' @usage NULL
#' @aliases moving_average_convergence_divergence
#' @export
moving_average_convergence_divergence.default <- function(
	x,
	cols,
	fast = 12,
	slow = 26,
	signal = 9,
	...
) {
	## check if they are all numeric
	## or calls
	is_calls <- vapply(
		list(fast, slow, signal),
		FUN = function(x) {
			inherits(x, "ma_specification")
		},
		logical(1L)
	)

	if (!(all(is_calls) || all(!is_calls))) {
		stop(
			"Either all of `fast`, `slow` and `signal` is specified as calls, or none at all. See examples for more details."
		)
	}

	## construct series
	x <- series(
		x = cols,
		default = ~close,
		data = x,
		...
	)

	## if not passed as calls
	##
	if (!all(is_calls)) {
		if (fast == 12L && slow == 26L) {
			output <- .Call("impl_ta_MACDFIX", x[[1]], as.integer(signal))
		} else {
			output <- .Call(
				"impl_ta_MACD",
				x[[1]],
				as.integer(fast),
				as.integer(slow),
				as.integer(signal)
			)
		}

		output <- as.data.frame(
			output
		)

		return(output)
	}

	as.data.frame(
		.Call(
			"impl_ta_MACDEXT",
			x[[1]],
			fast$n,
			fast$maType,
			slow$n,
			slow$maType,
			signal$n,
			signal$maType
		)
	)
}

#' @usage NULL
#' @aliases moving_average_convergence_divergence
#' @export
moving_average_convergence_divergence.numeric <- function(
	x,
	cols,
	fast = 12,
	slow = 26,
	signal = 9,
	...
) {
	## determine branch
	## if its a matrix call
	## matrix method and end the function
	##
	## NOTE: this is necessary as matrix are
	##       internally doubles
	if (is.matrix(x)) {
		output <- NextMethod()

		return(output)
	}

	## treat 'x' as a vector
	##
	if (!missing(cols)) {
		warning(
			"'cols' have been passed but is unused in for vectors"
		)
	}

	## check if they are all numeric
	## or calls
	is_calls <- vapply(
		list(fast, slow, signal),
		FUN = function(x) {
			inherits(x, "ma_specification")
		},
		logical(1L)
	)

	if (!(all(is_calls) || all(!is_calls))) {
		stop(
			"Either all of `fast`, `slow` and `signal` is specified as calls, or none at all. See examples for more details."
		)
	}

	## construct series
	x <- series(
		x = cols,
		default = ~close,
		data = x,
		...
	)

	## if not passed as calls
	##
	if (!all(is_calls)) {
		if (fast == 12L && slow == 26L) {
			output <- .Call("impl_ta_MACDFIX", x, as.integer(signal))
		} else {
			output <- .Call(
				"impl_ta_MACD",
				x,
				as.integer(fast),
				as.integer(slow),
				as.integer(signal)
			)
		}

		output <- as.data.frame(
			output
		)

		return(output)
	}

	as.data.frame(
		.Call(
			"impl_ta_MACDEXT",
			x,
			fast$n,
			fast$maType,
			slow$n,
			slow$maType,
			signal$n,
			signal$maType
		)
	)
}

#' @usage NULL
#' @aliases moving_average_convergence_divergence
#' @export
moving_average_convergence_divergence.data.frame <- function(
	x,
	cols,
	fast = 12,
	slow = 26,
	signal = 9,
	...
) {
	as.data.frame(
		moving_average_convergence_divergence.default(
			x = x,
			cols = cols,
			fast = fast,
			slow = slow,
			signal = signal,
			...
		)
	)
}

#' @usage NULL
#' @aliases moving_average_convergence_divergence
#' @export
moving_average_convergence_divergence.matrix <- function(
	x,
	cols,
	fast = 12,
	slow = 26,
	signal = 9,
	...
) {
	as.matrix(
		moving_average_convergence_divergence.default(
			x = x,
			cols = cols,
			fast = fast,
			slow = slow,
			signal = signal,
			...
		)
	)
}

#' @usage NULL
#' @aliases moving_average_convergence_divergence
#' @export
moving_average_convergence_divergence.plotly <- function(
	x,
	cols,
	fast = 12,
	slow = 26,
	signal = 9,
	...
) {
	## prepare univariate
	## series for MACD
	x <- series(
		x = x,
		formula = cols,
		default = ~close,
		...
	)

	## calculator indicator
	## and return as data.frame
	.indicator <- moving_average_convergence_divergence.default(
		x = x,
		cols = rebuild_formula(
			names(x)
		),
		fast = fast,
		slow = slow,
		signal = signal
	)

	## add x-axis conditional on whether
	## the data have been subsetted or not
	.indicator$idx <- add_idx(
		x
	)

	## calculate directions for bull
	## and bear candles
	.indicator$direction <- .indicator$signal >= .indicator$macd

	## generate plotly object
	## of the indicator
	chart_theme <- .chart_theme()

	plotly_object <- plotly::layout(
		plotly::plot_ly(
			data = .indicator,
			showlegend = FALSE,
			name = 'MACD',
			x = ~idx,
			y = ~histogram,
			color = ~direction,
			colors = c(
				chart_theme$bull_color,
				chart_theme$bear_color
			),
			type = 'bar'
		),
		xaxis = list(
			tickvals = seq_along(.indicator$idx),
			ticktext = .indicator$idx,
			tickmode = "auto"
		)
	)

	plotly_object <- plotly::add_lines(
		plotly_object,
		x = ~idx,
		y = ~signal,
		data = .indicator,
		inherit = FALSE,
		name = sprintf(
			fmt = "Signal(%d)",
			if (is.list(signal)) signal$n else signal
		)
	)

	plotly_object <- plotly::add_lines(
		plotly_object,
		x = ~idx,
		y = ~macd,
		data = .indicator,
		inherit = FALSE,
		name = sprintf(
			fmt = "MACD(%d, %d)",
			if (is.list(fast)) fast$n else fast,
			if (is.list(slow)) slow$n else slow
		)
	)

	if (!is.null(.plotting_environment$main)) {
		plotly_object <- add_title(
			x = plotly_object,
			text = sprintf(
				fmt = "MACD(%d, %d, %d)",
				if (is.list(fast)) fast$n else fast,
				if (is.list(slow)) slow$n else slow,
				if (is.list(signal)) signal$n else signal
			)
		)
	}

	.plotting_environment$sub <- c(
		.plotting_environment$sub,
		list(plotly_object)
	)

	plotly_object
}
