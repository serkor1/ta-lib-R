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

#' @usage NULL
#' @aliases moving_average_convergence_divergence
#' @export
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
	## diffuse calls directly
	fast_expr <- substitute(fast)
	slow_expr <- substitute(slow)
	signal_expr <- substitute(signal)

	if (is.name(fast_expr) && identical(fast_expr, quote(fast))) {
		fast <- substitute(fast, parent.frame())
	} else {
		fast <- fast_expr
	}

	if (is.name(slow_expr) && identical(slow_expr, quote(slow))) {
		slow <- substitute(slow, parent.frame())
	} else {
		slow <- slow_expr
	}

	if (is.name(signal_expr) && identical(signal_expr, quote(signal))) {
		signal <- substitute(signal, parent.frame())
	} else {
		signal <- signal_expr
	}

	## check if they are all numeric
	## or calls
	is_calls <- vapply(
		list(fast, slow, signal),
		is.call,
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

	fast <- map_maType_call(fast)
	slow <- map_maType_call(slow)
	signal <- map_maType_call(signal)

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

	## diffuse calls directly
	fast <- substitute(fast)
	slow <- substitute(slow)
	signal <- substitute(signal)

	## check if they are all numeric
	## or calls
	is_calls <- vapply(
		list(fast, slow, signal),
		is.call,
		logical(1L)
	)

	if (!(all(is_calls) || all(!is_calls))) {
		stop(
			"Either all of `fast`, `slow` and `signal` is specified as calls, or none at all. See examples for more details."
		)
	}

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

	fast <- map_maType_call(fast)
	slow <- map_maType_call(slow)
	signal <- map_maType_call(signal)

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
	## prepare series
	## from
	x <- series(
		x = x,
		formula = cols,
		default = ~close,
		...
	)

	## construct indicator
	##
	.indicator <- moving_average_convergence_divergence.default(
		x = x,
		cols = cols,
		fast = fast,
		slow = slow,
		signal = signal
	)

	.indicator$idx <- 1:nrow(.indicator)
	.indicator$direction <- .indicator$signal >= .indicator$macd

	## generate indicator plot
	output <- plotly::plot_ly(
		data = .indicator,
		showlegend = FALSE,
		name = 'MACD',
		x = ~idx,
		y = ~histogram,
		color = ~direction,
		colors = c(
			chart.theme()$bull_color,
			chart.theme()$bear_color
		),
		type = 'bar'
	)

	output <- plotly::add_lines(
		output,
		x = ~idx,
		y = ~signal,
		data = .indicator,
		inherit = FALSE
	)

	output <- plotly::add_lines(
		output,
		x = ~idx,
		y = ~macd,
		data = .indicator,
		inherit = FALSE
	)

	output <- add_title(
		x = output,
		text = "MACD"
	)

	.plotting_environment$sub <- c(
		.plotting_environment$sub,
		list(output)
	)

	output
}
