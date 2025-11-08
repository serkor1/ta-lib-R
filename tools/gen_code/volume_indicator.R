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
		family = "Volume Indicator",
		fun = x$fun,
		args = x$signature,
		ta_fun = x$alias,
		formula = x$default_formula
	)
}

generate_C <- function(x) {
	system2(
		command = "bash",
		args = c(
			"tools/generate_indicator_core.sh",
			paste0(x$alias, " > src/ta_", x$alias, ".c")
		)
	)
}

## 2) metadata
metadata <- list()

## Chaikin A/D Line: metadata
metadata[[1]] <- list(
	title = 'Chaikin A/D Line',
	fun = 'chaikin_accumulation_distribution_line',
	alias = 'AD',
	default_formula = '~high+low+close+volume',
	signature = ''
)

## Chaikin A/D Oscillator: metadata
metadata[[2]] <- list(
	title = 'Chaikin A/D Oscillator',
	fun = 'chaikin_accumulation_distribution_oscillator',
	alias = 'ADOSC',
	default_formula = '~high+low+close+volume',
	signature = 'fast=3,slow=10'
)

## On-Balance Volume: metadata
metadata[[3]] <- list(
	title = 'On-Balance Volume',
	fun = 'on_balance_volume',
	alias = 'OBV',
	default_formula = '~close+volume',
	signature = ''
)

## generate code
for (x in metadata) {
	generate_R(x)
}

for (x in metadata) {
	generate_C(x)
}

## end script;
