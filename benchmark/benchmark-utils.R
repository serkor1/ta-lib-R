## benchmark/benchmark-utils.R
##
## Shared helpers for the talib benchmark suite. The benchmarks compare:
##   1. The raw .Call into talib's C entry points (no R overhead).
##   2. talib's data.frame and matrix S3 methods around that .Call.
##   3. The equivalent TTR implementation, called with its natural API.
##
## Everything here is dependency-free (base R only) so the helpers load
## even when only {bench}, {ggplot2}, {talib}, and {TTR} are installed.


## Configuration

## Observation counts to sweep over. Log-spaced because the plots use a
## log x-axis; four points keep the grid readable while still spanning
## three orders of magnitude.
BENCHMARK_SIZES <- as.integer(c(1e3, 1e4, 1e5, 1e6))

## Number of timed iterations bench::mark runs per (expression, n) cell.
BENCHMARK_ITERATIONS <- 1000L

## Calls made against each expression before timing starts. Three is
## enough to prime CPU caches, branch predictors, and the R allocator
## for the data size we are about to time.
BENCHMARK_WARMUP <- 3L


## Synthetic data

## Build an OHLCV data.frame with n rows. We construct the series so
## that high >= max(open, close) and low <= min(open, close); both talib
## and TTR assume that contract on HLC indicators (ATR, ADX, STOCH).
## The seed is fixed so every (indicator, n) cell sees the same data,
## which keeps the comparison fair across runs.
make_ohlc <- function(n, seed = 1903L) {
	set.seed(seed)
	open <- runif(n, min = 100, max = 1000)
	close <- open + stats::rnorm(n, mean = 0, sd = 5)
	wick <- abs(stats::rnorm(n, mean = 10, sd = 5))
	high <- pmax(open, close) + wick
	low <- pmin(open, close) - wick
	volume <- runif(n, min = 1e6, max = 1e7)

	data.frame(
		open = open,
		high = high,
		low = low,
		close = close,
		volume = volume
	)
}


## Warmup

## Call each nullary function reps times. We do not need the results;
## the goal is to pull the data into cache and let R amortise any
## first-call costs (function lookup, allocator slabs) before bench::mark
## starts measuring.
warmup <- function(fns, reps = BENCHMARK_WARMUP) {
	for (i in seq_len(reps)) {
		for (fn in fns) {
			invisible(fn())
		}
	}
	invisible(NULL)
}


## Tidying

## Pull the numeric columns out of a bench::mark result and tag every
## row with the indicator name and the size n. {bench} stores per-iter
## timings as list columns; we collapse them to plain doubles (in
## seconds) so the result round-trips through saveRDS cleanly and so the
## ggplot2 layer below has nothing fancy to handle.
tidy_bench <- function(x, indicator, n) {
	data.frame(
		indicator = indicator,
		n = n,
		spec = as.character(x[["expression"]]),
		min = as.numeric(x[["min"]]),
		median = as.numeric(x[["median"]]),
		mean = vapply(
			x[["time"]],
			function(t) mean(as.numeric(t)),
			numeric(1)
		),
		max = vapply(
			x[["time"]],
			function(t) max(as.numeric(t)),
			numeric(1)
		),
		itr_per_sec = as.numeric(x[["itr/sec"]]),
		mem_alloc = as.numeric(x[["mem_alloc"]]),
		n_itr = as.integer(x[["n_itr"]]),
		n_gc = as.integer(x[["n_gc"]]),
		stringsAsFactors = FALSE
	)
}


## Progress reporting

## One line per cell, padded so the indicator name lines up with the
## sibling output from bench::mark. Used purely so a long run is not a
## silent black box.
banner <- function(label, n) {
	message(sprintf(
		"  [%-12s] n = %s",
		label,
		format(n, big.mark = ",", scientific = FALSE)
	))
}
