#' @usage NULL
#' @aliases moving_average_convergence_divergence
#' @export
MACDEXT <- function(
	x,
	cols,
	fast = EMA(n = 12),
	slow = EMA(n = 26),
	signal = EMA(n = 9),
	...
) {
	moving_average_convergence_divergence(
		x = x,
		cols = cols,
		fast = fast,
		slow = slow,
		signal = signal,
		...
	)
}
