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
		family = "Volatility Indicator",
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

## True Range: metadata
metadata[[1]] <- list(
	title = 'True Range',
	fun = 'true_range',
	alias = 'TRANGE',
	default_formula = '~high + low + close',
	signature = ''
)

## Average True Range: metadata
metadata[[2]] <- list(
	title = 'Average True Range',
	fun = 'average_true_range',
	alias = 'ATR',
	default_formula = '~high + low + close',
	signature = 'n=10'
)

## Normalized Average True Range: metadata
metadata[[3]] <- list(
	title = 'Normalized Average True Range',
	fun = 'normalized_average_true_range',
	alias = 'NATR',
	default_formula = '~high + low + close',
	signature = 'n=10'
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
