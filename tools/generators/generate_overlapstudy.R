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
			paste0("'", 'Overlap Study', "'"),
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
		'Bollinger Bands',
		'Hilbert Transform - Instantaneous Trendline',
		'Parabolic Stop and Reverse (SAR)',
		'Parabolic Stop and Reverse (SAR) - Extended',
		'Acceleration Bands'
	),
	fun = c(
		'bollinger_bands',
		'trendline',
		'parabolic_stop_and_reverse',
		'extended_parabolic_stop_and_reverse',
		'acceleration_bands'
	),
	signature = c(
		'ma=SMA(n=10),std_up=2,std_down=2',
		'',
		'acceleration=0.5,maximum=0.75',
		'init=0,offset=0,init_long=0,long=0,max_long=0,init_short=0,short=0,max_short=0',
		'n=10'
	),
	default_formula = c(
		'~close',
		'~close',
		'~high+low',
		'~high+low',
		'~open+high+close'
	),
	alias = c(
		'BBANDS',
		'HT_TRENDLINE',
		'SAR',
		'SAREXT',
		'ACCBANDS'
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
