## script: benchmark-overhead
## objective:
##
## Create a naïve benchmark comparing
## the C implementation to the R wrapper
## to determine the amount of overhead
## induced by the wrapper
##
## 1) load libraries
##    and data
library(talib)
DF <- readRDS("benchmark/dataframe.rds")
X <- readRDS("benchmark/matrix.rds")

## 2) load utils
source("benchmark/benchmark-utils.R")

## 3) construct wrappers
##    for benchmarking
##
## 3.1) direct call to 'C'
##      without any processing
##      this is the baseline
foo <- function() {
	.Call(
		"impl_ta_BBANDS",
		DF$close,
		10L,
		2,
		2,
		0L,
		PACKAGE = "talib"
	)
}

## 3.2) <data.frame>
bar <- function() {
	talib:::bollinger_bands(
		DF
	)
}

## 3.3) <matrix>
baz <- function() {
	talib::bollinger_bands(
		X
	)
}

## 4) benchmark
##
## 4.1) check that all core values
##      are equal
##
##		NOTE: all values can just be converted
##            to a long vector and compare the values
stopifnot(
	all.equal(
		as.double(foo()),
		as.double(as.matrix(bar())),
		check.attributes = FALSE,
		check.class = FALSE
	)
)

stopifnot(
	all.equal(
		as.double(foo()),
		as.double(baz()),
		check.attributes = FALSE,
		check.class = FALSE
	)
)

## 4.2) store the benchmark
##      so it can be exported
benchmark_results <- benchmark(
	"baseline" = foo(),
	"data.frame" = bar(),
	"matrix" = baz()
)

## 4.2) print the necessary
##      results
pretty(
	x = benchmark_results,
	indicator = "Bollinger Bands",
	n = nrow(DF)
)

## 4.3) store the benchmark
##      results
saveRDS(
	benchmark_results,
	"benchmark/overhead_benchmark.rds"
)
