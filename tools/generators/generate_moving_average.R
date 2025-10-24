## generate indicators
## from
generate_indicator <- function(
	family,
	title,
	fun,
	signature,
	default_formula,
	alias
) {
	system2(
		command = "bash",
		args = c(
			"tools/generate_indicator.sh",
			'moving_average_template.R',
			paste0("'", family, "'"),
			paste0("'", title, "'"),
			paste0("'", fun, "'"),
			paste0("'", signature, "'"),
			paste0("'", default_formula, "'"),
			paste0("'", alias, "'")
		)
	)
}


DT <- data.table::data.table(
	family = 'Overlap Study',
	title = c(
		'Simple Moving Average',
		'Exponential Moving Average',
		'Weighted Moving Average',
		'Double Exponential Moving Average',
		'Triple Exponential Moving Average',
		'Triangular Moving Average',
		'Kaufman Adaptive Moving Average',
		'MESA Adaptive Moving Average',
		'Triple Exponential Moving Average (T3)'
	),
	fun = c(
		'simple_moving_average',
		'exponential_moving_average',
		'weighted_moving_average',
		'double_exponential_moving_average',
		'triple_exponential_moving_average',
		'triangular_moving_average',
		'kaufman_adaptive_moving_average',
		'mesa_adaptive_moving_average',
		't3_exponential_moving_average'
	),
	alias = c(
		'SMA',
		'EMA',
		'WMA',
		'DEMA',
		'TEMA',
		'TRIMA',
		'KAMA',
		'MAMA',
		'T3'
	),
	default_formula = c(
		'0L',
		'1L',
		'2L',
		'3L',
		'4L',
		'5L',
		'6L',
		'7L',
		'8L'
	),
	signature = c(
		'0L',
		'1L',
		'2L',
		'3L',
		'4L',
		'5L',
		'6L',
		'7L',
		'8L'
	)
)

for (i in 1:nrow(DT)) {
	generate_indicator(
		family = DT$family[i],
		title = DT$title[i],
		fun = DT$fun[i],
		signature = DT$signature[i],
		default_formula = DT$default_formula[i],
		alias = DT$alias[i]
	)
}
