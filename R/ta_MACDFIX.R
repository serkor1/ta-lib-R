#' @usage NULL
#' @aliases moving_average_convergence_divergence
#' @export
MACDFIX <- function(
	x,
	cols,
	signal = 9,
	...
) {
	moving_average_convergence_divergence(
		x = x,
		cols = cols,
		fast = 12L,
		slow = 26L,
		signal = signal,
		...
	)
}
