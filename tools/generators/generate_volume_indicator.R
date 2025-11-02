## script: Generate 'Overlap Study'-indicators
## objective:
## author:
##
##
## 1) define all momentum
##    indicators as list
meta <- list()

## Chaikin A/D Line: metadata
meta[[1]] <- list(
	title = 'Chaikin A/D Line',
	fun = 'chaikin_accumulation_distribution_line',
	alias = 'AD',
	default_formula = '~high+low+close+volume',
	signature = ''
)

## Chaikin A/D Oscillator: metadata
meta[[2]] <- list(
	title = 'Chaikin A/D Oscillator',
	fun = 'chaikin_accumulation_distribution_oscillator',
	alias = 'ADOSC',
	default_formula = '~high+low+close+volume',
	signature = 'fast=3,slow=10'
)

## On-Balance Volume: metadata
meta[[3]] <- list(
	title = 'On-Balance Volume',
	fun = 'on_balance_volume',
	alias = 'OBV',
	default_formula = '~close+volume',
	signature = ''
)


## 2) generate a wrapper
##    that accepts a list
source("tools/generators/generate_functions.R")

generate <- function(
	x
) {
	generate_volume_indicator(
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
