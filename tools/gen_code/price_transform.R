## script: Price Transform
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
		family = "Price Transform",
		fun = x$fun,
		args = '',
		formula = x$formula,
		ta_fun = x$alias,
		plotly = 0,
		rolling = 0
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

## meta data
metadata <- list()

## Average Price
metadata[[1]] <- list(
	title = 'Average Price',
	alias = 'AVGPRICE',
	fun = 'average_price',
	formula = '~open + high + low + close'
)

## Median Price
metadata[[2]] <- list(
	title = 'Median Price',
	alias = 'MEDPRICE',
	fun = 'median_price',
	formula = '~high + low'
)

## Typical Price
metadata[[3]] <- list(
	title = 'Typical Price',
	alias = 'TYPPRICE',
	fun = 'typical_price',
	formula = '~high + low + close'
)

## Weighted Close Price
metadata[[4]] <- list(
	title = 'Weighted Close Price',
	alias = 'WCLPRICE',
	fun = 'weighted_close_price',
	formula = '~high + low + close'
)

## generate code
for (x in metadata) {
	generate_C(x)
	generate_R(x)
}
