## script: momentum functions
## objective:
## construct relevant metadata for generators
## downstream
##
## start script;
## 1) load abstractions
source("tools/gen_code/utils.R")

## 1.1) construct wrappers
generate_R <- function(x) {
	impl_generate_indicator(
		title = x$title,
		family = "Momentum Indicator",
		fun = x$fun,
		args = x$signature,
		ta_fun = x$alias,
		formula = x$default_formula
	)
}

generate_C <- function(x, safe = TRUE) {
	if (x$alias == "STOCHRSI") {
		warning(
			"Skipping Stochastich RSI. If you insist run with 'safe' = FALSE"
		)

		## exit function if safe
		if (safe) {
			return(NULL)
		}
	}
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

## Aroon: metadata
metadata[[1]] <- list(
	title = "Aroon",
	fun = "aroon",
	alias = "AROON",
	default_formula = "~ high + low",
	signature = c("n=10")
)

## Aroon Oscillator: metadata
metadata[[2]] <- list(
	title = "Aroon Oscillator",
	fun = "aroon_oscillator",
	alias = "AROONOSC",
	default_formula = "~ high + low",
	signature = c("n=10")
)

## Chande Momentum Oscillator: metadata
metadata[[3]] <- list(
	title = "Chande Momentum Oscillator",
	fun = "chande_momentum_oscillator",
	alias = "CMO",
	default_formula = "~ close",
	signature = c("n=10")
)

## Commodity Channel Index: metadata
metadata[[4]] <- list(
	title = "Commodity Channel Index",
	fun = "commodity_channel_index",
	alias = "CCI",
	default_formula = "~ high + low + close",
	signature = c("n=10")
)

## Fast Stochastic: metadata
metadata[[5]] <- list(
	title = "Fast Stochastic",
	fun = "fast_stochastic",
	alias = "STOCHF",
	default_formula = "~ high + low + close",
	signature = c("fastk=5", "fastd=SMA(n=10)")
)

## Money Flow Index: metadata
metadata[[6]] <- list(
	title = "Money Flow Index",
	fun = "money_flow_index",
	alias = "MFI",
	default_formula = "~ high + low + close + volume",
	signature = c("n = 10")
)

## Moving Average Convergence Divergence: metadata
metadata[[7]] <- list(
	title = "Moving Average Convergence Divergence",
	fun = "moving_average_convergence_divergence",
	alias = "MACD",
	default_formula = "~close",
	signature = c("fast = 12", "slow = 26", "signal = 9")
)

## Moving Average Convergence Divergence (Extended): metadata
metadata[[8]] <- list(
	title = "Moving Average Convergence Divergence (Extended)",
	fun = "extended_moving_average_convergence_divergence",
	alias = "MACDEXT",
	default_formula = "~close",
	signature = c(
		"fast = EMA(n = 12)",
		"slow = EMA(n = 26)",
		"signal = EMA(n = 9)"
	)
)

## Moving Average Convergence Divergence (Fixed): metadata
metadata[[9]] <- list(
	title = "Moving Average Convergence Divergence (Fixed)",
	fun = "fixed_moving_average_convergence_divergence",
	alias = "MACDFIX",
	default_formula = "~close",
	signature = c("signal=9")
)

## Relative Strength Index: metadata
metadata[[10]] <- list(
	title = "Relative Strength Index",
	fun = "relative_strength_index",
	alias = "RSI",
	default_formula = "~close",
	signature = c("n=10")
)

## Stochastic: metadata
metadata[[11]] <- list(
	title = "Stochastic",
	fun = "stochastic",
	alias = "STOCH",
	default_formula = "~ high + low + close",
	signature = c("fastk = 5", "slowk = SMA(n = 10)", "slowd = SMA(n = 8)")
)

## Stochastic Relative Strength Index: metadata
metadata[[12]] <- list(
	title = "Stochastic Relative Strength Index",
	fun = "stochastic_relative_strength_index",
	alias = "STOCHRSI",
	default_formula = "~ high + low + close",
	signature = c("n=10", "n_rsi=10", "fastk=5", "fastd=SMA(n=10)")
)

## Ultimate Oscillator: metadata
metadata[[13]] <- list(
	title = "Ultimate Oscillator",
	fun = "ultimate_oscillator",
	alias = "ULTOSC",
	default_formula = "~ high + low + close",
	signature = c("n=c(7, 14, 28)")
)

## Average Directional Movement Index: metadata
metadata[[14]] <- list(
	title = "Average Directional Movement Index",
	fun = "average_directional_movement_index",
	alias = "ADX",
	default_formula = "~ high + low + close",
	signature = c("n=10")
)

## Average Directional Movement Index Rating: metadata
metadata[[15]] <- list(
	title = "Average Directional Movement Index Rating",
	fun = "average_directional_movement_index_rating",
	alias = "ADXR",
	default_formula = "~ high + low + close",
	signature = c("n=10")
)

## Balance of Power: metadata
metadata[[16]] <- list(
	title = "Balance of Power",
	fun = "balance_of_power",
	alias = "BOP",
	default_formula = "~ open + high + low + close",
	signature = c(character(0))
)

## Momentum: metadata
metadata[[17]] <- list(
	title = "Momentum",
	fun = "momentum",
	alias = "MOM",
	default_formula = "~ close",
	signature = c("n=10")
)

## Williams %R: metadata
metadata[[18]] <- list(
	title = "Williams %R",
	fun = "williams_oscillator",
	alias = "WILLR",
	default_formula = "~ high + low + close",
	signature = c("n=10")
)

## Percentage Price Oscillator: metadata
metadata[[19]] <- list(
	title = "Percentage Price Oscillator",
	fun = "percentage_price_oscillator",
	alias = "PPO",
	default_formula = "~close",
	signature = c("fast=7", "slow=14", "ma=SMA(n=10)")
)

## Triple Exponential Average: metadata
metadata[[20]] <- list(
	title = "Triple Exponential Average",
	fun = "triple_exponential_average",
	alias = "TRIX",
	default_formula = "~close",
	signature = c("n=10")
)

## Directional Movement Index: metadata
metadata[[21]] <- list(
	title = "Directional Movement Index",
	fun = "directional_movement_index",
	alias = "DX",
	default_formula = "~high + low + close",
	signature = c("n=10")
)

## Intraday Movement Index: metadata
metadata[[22]] <- list(
	title = "Intraday Movement Index",
	fun = "intraday_movement_index",
	alias = "IMI",
	default_formula = "~open + close",
	signature = c("n=10")
)

## Minus Directional Indicator: metadata
metadata[[23]] <- list(
	title = "Minus Directional Indicator",
	fun = "minus_directional_indicator",
	alias = "MINUS_DI",
	default_formula = "~high + low + close",
	signature = c("n=10")
)

## Minus Directional Movement: metadata
metadata[[24]] <- list(
	title = "Minus Directional Movement",
	fun = "minus_directional_movement",
	alias = "MINUS_DM",
	default_formula = "~high + low",
	signature = c("n=10")
)

## Plus Directional Indicator: metadata
metadata[[25]] <- list(
	title = "Plus Directional Indicator",
	fun = "plus_directional_indicator",
	alias = "PLUS_DI",
	default_formula = "~high + low + close",
	signature = c("n=10")
)

## Plus Directional Movement: metadata
metadata[[26]] <- list(
	title = "Plus Directional Movement",
	fun = "plus_directional_movement",
	alias = "PLUS_DM",
	default_formula = "~high + low",
	signature = c("n=10")
)

## Rate of Change: metadata
metadata[[27]] <- list(
	title = "Rate of Change",
	fun = "rate_of_change",
	alias = "ROC",
	default_formula = "~close",
	signature = c("n=10")
)

## Ratio of Change: metadata
metadata[[28]] <- list(
	title = "Ratio of Change",
	fun = "ratio_of_change",
	alias = "ROCR",
	default_formula = "~close",
	signature = c("n=10")
)

metadata[[29]] <- list(
	title = "Absolute Price Oscillator",
	fun = "absolute_price_oscillator",
	alias = "APO",
	default_formula = "~close",
	signature = c("fast=7", "slow=14", "ma=SMA(n=10)")
)

for (x in metadata) {
	generate_R(x)
}

# for (x in metadata) {
# 	generate_C(x)
# }

## end script;
