## script: Generate Functions
## objective:
## Consolidate functions
## for generators
##
##
## 1) main generator function
impl_generate_indicator <- function(
	title,
	fun,
	family,
	ta_fun,
	formula,
	plotly = 1L,
	args,
	agnostic = NULL,
	candlestick = 0,
	maType = -1,
	rolling = 0
) {
	args <- gsub("([()])", "\\\\\\1", args, perl = TRUE)
	args <- gsub("\\s+", "", args, perl = TRUE)
	system2(
		command = "bash",
		args = c("./tools/generate_indicator.sh", args),
		env = c(
			sprintf("TITLE='%s'", title),
			sprintf("FUN='%s'", fun),
			sprintf("FAMILY='%s'", family),
			sprintf("TA_FUN='%s'", ta_fun),
			sprintf("FORMULA='%s'", formula),
			sprintf("PLOTLY='%s'", plotly),
			sprintf("AGNOSTIC='%s'", agnostic),
			sprintf("CANDLESTICK='%s'", candlestick),
			sprintf("maType='%s'", maType),
			sprintf("ROLLING='%s'", rolling),
			sprintf(
				"NUMERIC='%s'",
				as.integer(
					as.logical(
						length(all.vars(as.formula(formula))) == 1
					)
				)
			)
		)
	)
}

## 2) generate_candlestick
##    patterns
generate_candlestick <- function(
	title,
	fun,
	alias,
	signature,
	agnostic
) {
	impl_generate_indicator(
		template = 'candlestick_template.R',
		title = title,
		alias = alias,
		fun = fun,
		default_formula = agnostic,
		signature = signature
	)
}

## 3) generate momentum
##    indicators
generate_momentum_indicator <- function(
	title,
	fun,
	alias,
	signature,
	default_formula
) {
	impl_generate_indicator(
		template = 'indicator_template.R',
		family = 'Momentum Indicator',
		title = title,
		alias = alias,
		fun = fun,
		default_formula = default_formula,
		signature = signature
	)
}

## 4) generate moving averages
generate_moving_average <- function(
	title,
	fun,
	alias,
	maType
) {
	impl_generate_indicator(
		template = 'moving_average_template.R',
		family = 'Overlap Study',
		title = title,
		alias = alias,
		fun = fun,
		default_formula = maType,
		signature = maType
	)
}

## 5) generate overlap study
generate_overlap_study <- function(
	title,
	fun,
	alias,
	default_formula,
	signature
) {
	impl_generate_indicator(
		template = 'indicator_template.R',
		family = 'Overlap Study',
		title = title,
		alias = alias,
		fun = fun,
		default_formula = default_formula,
		signature = signature
	)
}

## 6) generate cycle indicator
generate_cycle_indicator <- function(
	title,
	fun,
	alias
) {
	impl_generate_indicator(
		template = 'indicator_template.R',
		family = 'Cycle Indicator',
		title = title,
		alias = alias,
		fun = fun,
		default_formula = '~close',
		signature = ''
	)
}

## 7) generate volume indicator
generate_volume_indicator <- function(
	title,
	fun,
	alias,
	default_formula,
	signature
) {
	impl_generate_indicator(
		template = 'indicator_template.R',
		family = 'Volume Indicator',
		title = title,
		alias = alias,
		fun = fun,
		default_formula = default_formula,
		signature = signature
	)
}

## 7) generate volatility indicator
generate_volatility_indicator <- function(
	title,
	fun,
	alias,
	default_formula,
	signature
) {
	impl_generate_indicator(
		template = 'indicator_template.R',
		family = 'Volatility Indicator',
		title = title,
		alias = alias,
		fun = fun,
		default_formula = default_formula,
		signature = signature
	)
}
