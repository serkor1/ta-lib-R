## script: Rolling Statistics
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
		family = "Rolling Statistic",
		fun = x$fun,
		args = x$signature,
		formula = x$formula,
		ta_fun = x$alias,
		plotly = 0,
		rolling = 1
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

## rolling sum
metadata[[1]] <- list(
	title = 'Rolling Sum',
	fun = 'rolling_sum',
	ta_fun = 'SUM',
	alias = 'SUM',
	signature = 'n = 10'
)

## rolling standarddeviation
metadata[[2]] <- list(
	title = 'Rolling Standard Deviation',
	fun = 'rolling_standard_deviation',
	ta_fun = 'STDDEV',
	alias = 'STDDEV',
	signature = c('n=10', 'deviation = 1')
)

## rolling variance
metadata[[3]] <- list(
	title = 'Rolling Standard Deviation',
	fun = 'rolling_variance',
	ta_fun = 'VAR',
	alias = 'VAR',
	signature = c('n=10', 'deviation = 1')
)

## rolling beta
metadata[[4]] <- list(
	title = 'Rolling Beta',
	fun = 'rolling_beta',
	ta_fun = 'BETA',
	alias = 'BETA',
	signature = c('y', 'n=10')
)

## rolling correlation
metadata[[5]] <- list(
	title = 'Rolling Correlation',
	fun = 'rolling_correlation',
	ta_fun = 'CORREL',
	alias = 'CORREL',
	signature = c('y', 'n=10')
)

## rolling max
metadata[[6]] <- list(
	title = 'Rolling Max',
	fun = 'rolling_max',
	ta_fun = 'MAX',
	alias = 'MAX',
	signature = c('n=10')
)

## rolling min
metadata[[7]] <- list(
	title = 'Rolling Min',
	fun = 'rolling_min',
	ta_fun = 'MIN',
	alias = 'MIN',
	signature = c('n=10')
)

## generate code
for (x in metadata) {
	generate_C(
		x
	)
}

for (x in metadata) {
	generate_R(
		x
	)
}
