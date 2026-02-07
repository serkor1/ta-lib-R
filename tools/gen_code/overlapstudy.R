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
		formula = x$default_formula,
		ta_fun = x$alias,
		subchart = x$subcart
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

## Bollinger Bands: metadata
metadata[[1]] <- list(
	title = 'Bollinger Bands',
	fun = 'bollinger_bands',
	alias = 'BBANDS',
	default_formula = '~close',
	signature = 'ma=SMA(n=10),std_up=2,std_down=2',
	subchart = 0L
)

## Hilbert Transform - Instantaneous Trendline: metadata
metadata[[2]] <- list(
	title = 'Hilbert Transform - Instantaneous Trendline',
	fun = 'trendline',
	alias = 'HT_TRENDLINE',
	default_formula = '~close',
	signature = '',
	subchart = 0L
)

## Parabolic Stop and Reverse (SAR): metadata
metadata[[3]] <- list(
	title = 'Parabolic Stop and Reverse (SAR)',
	fun = 'parabolic_stop_and_reverse',
	alias = 'SAR',
	default_formula = '~high+low',
	signature = 'acceleration=0.5,maximum=0.75',
	subchart = 0L
)

## Parabolic Stop and Reverse (SAR) - Extended: metadata
metadata[[4]] <- list(
	title = 'Parabolic Stop and Reverse (SAR) - Extended',
	fun = 'extended_parabolic_stop_and_reverse',
	alias = 'SAREXT',
	default_formula = '~high+low',
	signature = 'init=0,offset=0,init_long=0,long=0,max_long=0,init_short=0,short=0,max_short=0',
	subchart = 0L
)

## Acceleration Bands: metadata
metadata[[5]] <- list(
	title = 'Acceleration Bands',
	fun = 'acceleration_bands',
	alias = 'ACCBANDS',
	default_formula = '~ high + low + close',
	signature = 'n=10',
	subchart = 0L
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
