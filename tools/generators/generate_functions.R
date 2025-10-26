## script: Generate Functions
## objective:
## Consolidate functions
## for generators
##
##
## 1) main generator function
impl_generate_indicator <- function(
	template,
	family,
	title,
	fun,
	signature,
	default_formula,
	alias
) {
	## set all missing values
	## to ' ' so we avoid shenanigans
	if (missing(family)) {
		family <- ' '
	}
	if (missing(title)) {
		title <- ' '
	}
	if (missing(fun)) {
		fun <- ' '
	}
	if (missing(signature)) {
		signature <- ' '
	}
	if (missing(alias)) {
		alias <- ' '
	}

	system2(
		command = "bash",
		args = c(
			"tools/generate_indicator.sh",
			template,
			paste0("'", family, "'"),
			paste0("'", title, "'"),
			paste0("'", fun, "'"),
			paste0("'", signature, "'"),
			paste0("'", default_formula, "'"),
			paste0("'", alias, "'")
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
