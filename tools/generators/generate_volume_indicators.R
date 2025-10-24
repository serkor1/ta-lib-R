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
			paste0("'", 'Volumne Indicator', "'"),
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
		'Chaikin A/D Line',
		'Chaikin A/D Oscillator',
		'On-Balance Volume'
	),
	fun = c(
		'chaikin_accumulation_distribution_line',
		'chaikin_accumulation_distribution_oscillator',
		'on_balance_volume'
	),
	signature = c(
		'',
		'fast=3,slow=10',
		''
	),
	default_formula = c(
		'~high+low+close+volume',
		'~high+low+close+volume',
		'~close+volume'
	),
	alias = c(
		'AD',
		'ADOSC',
		'OBV'
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
