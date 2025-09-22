#' @usage NULL
#' @aliases moving_average_convergence_divergence
#' @export
MACDFIX <- function(
	x,
	cols,
	signal = 9,
	...
) {
	matched_call <- match.call(expand.dots = TRUE)
	function_formals <- formals(sys.function())

	miss <- setdiff(names(function_formals), names(matched_call))
	miss <- setdiff(miss, "...") # can't default ...
	for (nm in miss) {
		matched_call[[nm]] <- function_formals[[nm]]
	}

	pkg <- utils::packageName(environment())
	matched_call[[1L]] <- call(
		"::",
		as.name(pkg),
		as.name("moving_average_convergence_divergence")
	)
	eval(matched_call, parent.frame())
}
