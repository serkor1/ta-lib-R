## script: candlestick functions
## objective:
## construct relevant metadata for generators downstream
##
## start script;
## 1) load abstractions
source("tools/gen_code/utils.R")

## 1.1) construct wrappers
generate_R <- function(x) {
	impl_generate_indicator(
		title = x$title,
		family = "Overlap Study",
		fun = x$fun,
		args = x$signature,
		ta_fun = x$alias,
		formula = x$default_formula,
		maType = x$ma_type,
		plotly = 0
	)
}

generate_C <- function(x) {
	if (file.exists("src/ta_MA.c")) {
		warning("The file already exist. It needs to be constructed manually")
		return(NULL)
	}

	system2(
		command = "bash",
		args = c(
			"tools/generate_indicator_core.sh",
			'MA > src/ta_MA.c'
		)
	)
}

generate_test <- function(x) {
	impl_generate_test(
		fun = x$fun,
		ta_fun = x$alias,
		formula = x$default_formula,
		plotly = 1,
		rolling = 0,
		args = x$signature
	)
}

## 2) metadata
metadata <- list()

## Simple Moving Average: metadata
metadata[[1]] <- list(
	title = 'Simple Moving Average',
	fun = 'simple_moving_average',
	alias = 'SMA',
	ma_type = '0L'
)

## Exponential Moving Average: metadata
metadata[[2]] <- list(
	title = 'Exponential Moving Average',
	fun = 'exponential_moving_average',
	alias = 'EMA',
	ma_type = '1L'
)

## Weighted Moving Average: metadata
metadata[[3]] <- list(
	title = 'Weighted Moving Average',
	fun = 'weighted_moving_average',
	alias = 'WMA',
	ma_type = '2L'
)

## Double Exponential Moving Average: metadata
metadata[[4]] <- list(
	title = 'Double Exponential Moving Average',
	fun = 'double_exponential_moving_average',
	alias = 'DEMA',
	ma_type = '3L'
)

## Triple Exponential Moving Average: metadata
metadata[[5]] <- list(
	title = 'Triple Exponential Moving Average',
	fun = 'triple_exponential_moving_average',
	alias = 'TEMA',
	ma_type = '4L'
)

## Triangular Moving Average: metadata
metadata[[6]] <- list(
	title = 'Triangular Moving Average',
	fun = 'triangular_moving_average',
	alias = 'TRIMA',
	ma_type = '5L'
)

## Kaufman Adaptive Moving Average: metadata
metadata[[7]] <- list(
	title = 'Kaufman Adaptive Moving Average',
	fun = 'kaufman_adaptive_moving_average',
	alias = 'KAMA',
	ma_type = '6L'
)

## MESA Adaptive Moving Average: metadata
metadata[[8]] <- list(
	title = 'MESA Adaptive Moving Average',
	fun = 'mesa_adaptive_moving_average',
	alias = 'MAMA',
	ma_type = '7L'
)

## Triple Exponential Moving Average (T3): metadata
metadata[[9]] <- list(
	title = 'Triple Exponential Moving Average (T3)',
	fun = 't3_exponential_moving_average',
	alias = 'T3',
	ma_type = '8L'
)

for (x in metadata) {
	generate_R(x)
}

for (x in metadata) {
	generate_C(x)
}

for (x in metadata) {
	generate_test(x)
}

## end script;
