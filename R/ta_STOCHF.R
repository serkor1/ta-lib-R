#' @title Fast Stochastic
#'
#' @family Momentum Indicator
#' @export
fast_stochastic <- function(
	x,
	fast_k,
	fast_d_MAtype = SMA(n = 10),
	...
) {
	UseMethod(
		"fast_stochastic"
	)
}

#' @export
STOCHF <- fast_stochastic

#' @export
fast_stochastic.default <- function(
	x,
	fast_k,
	fast_d_MAtype = SMA(n = 10),
	...
) {
	fast_d_MAtype <- map_maType_call(substitute(fast_d_MAtype))

	.Call(
		"impl_ta_STOCHF",
		.high(x),
		.low(x),
		.close(x),
		as.integer(fast_k),
		fast_d_MAtype$n,
		fast_d_MAtype$maType
	)
}
