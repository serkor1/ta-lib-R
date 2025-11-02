## script: Generate 'Overlap Study'-indicators
## objective:
## author:
##
##
## 1) define generator function
meta <- list()

## True Range: metadata
meta[[1]] <- list(
	title = 'True Range',
	fun = 'true_range',
	alias = 'TRANGE',
	default_formula = '~high + low + close',
	signature = ''
)

## Average True Range: metadata
meta[[2]] <- list(
	title = 'Average True Range',
	fun = 'average_true_range',
	alias = 'ATR',
	default_formula = '~high + low + close',
	signature = 'n=10'
)

## Normalized Average True Range: metadata
meta[[3]] <- list(
	title = 'Normalized Average True Range',
	fun = 'normalized_average_true_range',
	alias = 'NATR',
	default_formula = '~high + low + close',
	signature = 'n=10'
)

## 2) generate a wrapper
##    that accepts a list
source("tools/generators/generate_functions.R")

generate <- function(
	x
) {
	generate_volatility_indicator(
		title = x$title,
		fun = x$fun,
		signature = x$signature,
		alias = x$alias,
		default_formula = x$default_formula
	)
}

## 3) execute algorithm
##    and celebrate
for (x in meta) {
	generate(
		x
	)
}

## 4) generate candlestick C files
for (x in meta) {
	system2(
		command = "bash",
		args = c(
			"tools/generate_indicator_core.sh",
			paste0(x$alias, " > src/ta_", x$alias, ".c")
		)
	)
}
