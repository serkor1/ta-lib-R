## script: cycle indicator functions
## objective:
## construct relevant metadata for generators downstream
##
## start script;
## 1) load abstractions
source("tools/gen_code/utils.R")

## 1.1) construct wrappers
generate_R <- function(x) {
	generate_cycle_indicator(
		title = x$title,
		fun = x$fun,
		alias = x$alias
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

## Hilbert Transform - Dominant Cycle Period: metadata
metadata[[1]] <- list(
	title = 'Hilbert Transform - Dominant Cycle Period',
	fun = 'dominant_cycle_period',
	alias = 'HT_DCPERIOD'
)

## Hilbert Transform - Dominant Cycle Phase: metadata
metadata[[2]] <- list(
	title = 'Hilbert Transform - Dominant Cycle Phase',
	fun = 'dominant_cycle_phase',
	alias = 'HT_DCPHASE'
)

## Hilbert Transform - Phasor Components: metadata
metadata[[3]] <- list(
	title = 'Hilbert Transform - Phasor Components',
	fun = 'phasor_components',
	alias = 'HT_PHASOR'
)

## Hilbert Transform - SineWave: metadata
metadata[[4]] <- list(
	title = 'Hilbert Transform - SineWave',
	fun = 'sine_wave',
	alias = 'HT_SINE'
)

## Hilbert Transform - Trend vs Cycle Mode: metadata
metadata[[5]] <- list(
	title = 'Hilbert Transform - Trend vs Cycle Mode',
	fun = 'trend_cycle_mode',
	alias = 'HT_TRENDMODE'
)

## end script;
