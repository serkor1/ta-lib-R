## script: Generate 'Overlap Study'-indicators
## objective:
##
## There is no signature or default formula
## here. The functions are all based on close
## and has no further arguments
##
## author:
##
##
## 1) define generator function
meta <- list()

## Hilbert Transform - Dominant Cycle Period: metadata
meta[[1]] <- list(
	title = 'Hilbert Transform - Dominant Cycle Period',
	fun = 'dominant_cycle_period',
	alias = 'HT_DCPERIOD'
)

## Hilbert Transform - Dominant Cycle Phase: metadata
meta[[2]] <- list(
	title = 'Hilbert Transform - Dominant Cycle Phase',
	fun = 'dominant_cycle_phase',
	alias = 'HT_DCPHASE'
)

## Hilbert Transform - Phasor Components: metadata
meta[[3]] <- list(
	title = 'Hilbert Transform - Phasor Components',
	fun = 'phasor_components',
	alias = 'HT_PHASOR'
)

## Hilbert Transform - SineWave: metadata
meta[[4]] <- list(
	title = 'Hilbert Transform - SineWave',
	fun = 'sine_wave',
	alias = 'HT_SINE'
)

## Hilbert Transform - Trend vs Cycle Mode: metadata
meta[[5]] <- list(
	title = 'Hilbert Transform - Trend vs Cycle Mode',
	fun = 'trend_cycle_mode',
	alias = 'HT_TRENDMODE'
)

## 2) generate a wrapper that
##    that accepts a list
source("tools/generators/generate_functions.R")

generate <- function(
	x
) {
	generate_cycle_indicator(
		title = x$title,
		fun = x$fun,
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
