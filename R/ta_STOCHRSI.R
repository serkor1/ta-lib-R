#' @title Stochastic Relative Strength Index
#'
#' @family Momentum Indicator
#' @export
stochastic_relative_strength_index <- function(
	x,
	n,
	fast_k,
	fast_d_MAtype = SMA(n = 10),
	...
) {
	UseMethod(
		"stochastic_relative_strength_index"
	)
}

#' @export
STOCHRSI <- stochastic_relative_strength_index

#' @export
stochastic_relative_strength_index.default <- function(
	x,
	n,
	fast_k,
	fast_d_MAtype = SMA(n = 10),
	...
) {
	fast_d_MAtype <- map_maType_call(substitute(fast_d_MAtype))

	.Call(
		"impl_ta_STOCHRSI",
		x,
		as.integer(n),
		as.integer(fast_k),
		fast_d_MAtype$n,
		fast_d_MAtype$maType
	)
}
