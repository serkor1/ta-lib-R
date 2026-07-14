## script: Unified code generator
## objective:
## Single entry point that reads indicators.R metadata
## and generates R wrappers, C wrappers, and unit tests
## for every indicator.
##
## usage:
##   Rscript ./codegen/gen_code/generate.R

## 1) load helpers and metadata
source("codegen/gen_code/utils.R")
source("codegen/gen_code/indicators.R")

## 2) field accessor with defaults
`%||%` <- function(a, b) if (is.null(a)) b else a

## 3) generate R wrapper
generate_R <- function(x) {
	impl_generate_indicator(
		title = x$title,
		family = x$family,
		fun = x$fun,
		ta_fun = x$alias,
		formula = x$formula,
		args = x$signature,
		plotly = x$plotly %||% 1L,
		subchart = x$subchart %||% 1L,
		agnostic = x$agnostic,
		candlestick = x$candlestick %||% 0,
		maType = x$maType %||% -1,
		rolling = x$rolling %||% 0,
		univariate = x$univariate,
		n_default = x$n_default %||% 30L
	)
}

## 4) generate C wrapper
generate_C <- function(x) {}

## 5) generate unit test
generate_test <- function(x) {
	test_plotly <- x$test_plotly %||% (x$plotly %||% 1)

	impl_generate_test(
		fun = x$fun,
		ta_fun = x$alias,
		formula = x$formula,
		plotly = test_plotly,
		rolling = x$rolling %||% 0,
		args = x$signature
	)
}

## 6) run generation for all indicators
for (x in indicators) {
	generate_R(x)
	generate_C(x)
	generate_test(x)
}

## end script;
