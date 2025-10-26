## script: Generate 'Overlap Study'-indicators
## objective:
## author:
##
##
## 1) define generator function
meta <- list()

## Bollinger Bands: metadata
meta[[1]] <- list(
	title = 'Bollinger Bands',
	fun = 'bollinger_bands',
	alias = 'BBANDS',
	default_formula = '~close',
	signature = 'ma=SMA(n=10),std_up=2,std_down=2'
)

## Hilbert Transform - Instantaneous Trendline: metadata
meta[[2]] <- list(
	title = 'Hilbert Transform - Instantaneous Trendline',
	fun = 'trendline',
	alias = 'HT_TRENDLINE',
	default_formula = '~close',
	signature = ''
)

## Parabolic Stop and Reverse (SAR): metadata
meta[[3]] <- list(
	title = 'Parabolic Stop and Reverse (SAR)',
	fun = 'parabolic_stop_and_reverse',
	alias = 'SAR',
	default_formula = '~high+low',
	signature = 'acceleration=0.5,maximum=0.75'
)

## Parabolic Stop and Reverse (SAR) - Extended: metadata
meta[[4]] <- list(
	title = 'Parabolic Stop and Reverse (SAR) - Extended',
	fun = 'extended_parabolic_stop_and_reverse',
	alias = 'SAREXT',
	default_formula = '~high+low',
	signature = 'init=0,offset=0,init_long=0,long=0,max_long=0,init_short=0,short=0,max_short=0'
)

## Acceleration Bands: metadata
meta[[5]] <- list(
	title = 'Acceleration Bands',
	fun = 'acceleration_bands',
	alias = 'ACCBANDS',
	default_formula = '~open+high+close',
	signature = 'n=10'
)

## 2) generate a wrapper that
##    that accepts a list
source("tools/generators/generate_functions.R")

generate <- function(
	x
) {
	generate_overlap_study(
		title = x$title,
		fun = x$fun,
		signature = x$signature,
		default_formula = x$default_formula,
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
