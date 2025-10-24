## script: Generate 'Overlap Study'-indicators
## objective:
## author:
##
##
## 1) define generator function
generate_indicator <- function(
	title,
	fun,
	signature,
	default_formula,
	alias
) {
	system2(
		command = "bash",
		args = c(
			'tools/generate_indicator.sh',
			'indicator_template.R',
			paste0("'", 'Cycle Indicator', "'"),
			paste0("'", title, "'"),
			paste0("'", fun, "'"),
			paste0("'", signature, "'"),
			paste0("'", default_formula, "'"),
			paste0("'", alias, "'")
		)
	)
}

## 2) define function signatures
DT <- data.table::data.table(
	title = c(
		'Hilbert Transform - Dominant Cycle Period',
		'Hilbert Transform - Dominant Cycle Phase',
		'Hilbert Transform - Phasor Components',
		'Hilbert Transform - SineWave',
		'Hilbert Transform - Trend vs Cycle Mode'
	),
	fun = c(
		'dominant_cycle_period',
		'dominant_cycle_phase',
		'phasor_components',
		'sine_wave',
		'trend_cycle_mode'
	),
	signature = c(
		'',
		'',
		'',
		'',
		''
	),
	default_formula = c(
		'~close',
		'~close',
		'~close',
		'~close',
		'~close'
	),
	alias = c(
		'HT_DCPERIOD',
		'HT_DCPHASE',
		'HT_PHASOR',
		'HT_SINE',
		'HT_TRENDMODE'
	)
)

## 3) run
for (i in 1:nrow(DT)) {
	generate_indicator(
		title = DT$title[i],
		fun = DT$fun[i],
		signature = DT$signature[i],
		default_formula = DT$default_formula[i],
		alias = DT$alias[i]
	)
}
