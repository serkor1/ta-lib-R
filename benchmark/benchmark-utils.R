## script: benchmark-utils
## objective:
## 		create proper abstractions around
##      {bench} for running the benchmarks
##
## benchmark function
benchmark <- function(...) {
	## run benchmark
	x <- bench::mark(
		...,
		iterations = 1e3,
		# NOTE: there is no checks here as the
		#		comparision is three different methods
		check = FALSE
	)

	x
}

## pretty printer
pretty <- function(x, indicator, n) {
	cat("Benchmarking:", indicator, paste0("N = (", n, ")"), "\n")
	x[, c(1, 3, 5)]
}
