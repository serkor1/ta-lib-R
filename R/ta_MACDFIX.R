#' @family Momentum Indicator
#' @export
MACDFIX <- function(
	x,
	signal = 9,
	...
) {
	moving_average_convergence_divergence(
		x,
		12,
		26,
		signal,
		...
	)
}
