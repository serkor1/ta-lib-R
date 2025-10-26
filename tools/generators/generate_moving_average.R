meta <- list()

## Simple Moving Average: metadata
meta[[1]] <- list(
	title = 'Simple Moving Average',
	fun = 'simple_moving_average',
	alias = 'SMA',
	ma_type = '0L'
)

## Exponential Moving Average: metadata
meta[[2]] <- list(
	title = 'Exponential Moving Average',
	fun = 'exponential_moving_average',
	alias = 'EMA',
	ma_type = '1L'
)

## Weighted Moving Average: metadata
meta[[3]] <- list(
	title = 'Weighted Moving Average',
	fun = 'weighted_moving_average',
	alias = 'WMA',
	ma_type = '2L'
)

## Double Exponential Moving Average: metadata
meta[[4]] <- list(
	title = 'Double Exponential Moving Average',
	fun = 'double_exponential_moving_average',
	alias = 'DEMA',
	ma_type = '3L'
)

## Triple Exponential Moving Average: metadata
meta[[5]] <- list(
	title = 'Triple Exponential Moving Average',
	fun = 'triple_exponential_moving_average',
	alias = 'TEMA',
	ma_type = '4L'
)

## Triangular Moving Average: metadata
meta[[6]] <- list(
	title = 'Triangular Moving Average',
	fun = 'triangular_moving_average',
	alias = 'TRIMA',
	ma_type = '5L'
)

## Kaufman Adaptive Moving Average: metadata
meta[[7]] <- list(
	title = 'Kaufman Adaptive Moving Average',
	fun = 'kaufman_adaptive_moving_average',
	alias = 'KAMA',
	ma_type = '6L'
)

## MESA Adaptive Moving Average: metadata
meta[[8]] <- list(
	title = 'MESA Adaptive Moving Average',
	fun = 'mesa_adaptive_moving_average',
	alias = 'MAMA',
	ma_type = '7L'
)

## Triple Exponential Moving Average (T3): metadata
meta[[9]] <- list(
	title = 'Triple Exponential Moving Average (T3)',
	fun = 't3_exponential_moving_average',
	alias = 'T3',
	ma_type = '8L'
)

## 2) generate a wrapper
##    that accepts a list
source("tools/generators/generate_functions.R")

generate <- function(
	x
) {
	generate_moving_average(
		title = x$title,
		fun = x$fun,
		maType = x$ma_type,
		alias = x$alias
	)
}


## 3) execute algorithm
##    and celebrate
for (x in meta) {
	generate(
		x
	)
}
