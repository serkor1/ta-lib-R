## script: Generate Candlestick Patterns
## objective:
##
## Generate all available candlestick patterns
## based on the templates
##
## author: Serkan Korkmaz
##
## 1) define all candlestick
##    patterns as list
metadata <- list()

metadata[[1]] <- list(
	title = 'Abandoned Baby',
	fun = 'abandoned_baby',
	signature = 'eps = 0',
	alias = 'CDLABANDONEDBABY',
	agnostic = FALSE
)

metadata[[2]] <- list(
	title = 'Advance Block',
	fun = 'advance_block',
	signature = '',
	alias = 'CDLADVANCEBLOCK',
	agnostic = FALSE
)

metadata[[3]] <- list(
	title = 'Belt Hold',
	fun = 'belt_hold',
	signature = '',
	alias = 'CDLBELTHOLD',
	agnostic = FALSE
)

metadata[[4]] <- list(
	title = 'Break Away',
	fun = 'break_away',
	signature = '',
	alias = 'CDLBREAKAWAY',
	agnostic = FALSE
)

metadata[[5]] <- list(
	title = 'Closing Marubozu',
	fun = 'closing_marubozu',
	signature = '',
	alias = 'CDLCLOSINGMARUBOZU',
	agnostic = TRUE
)

metadata[[6]] <- list(
	title = 'Concealing Baby Swallow',
	fun = 'concealing_baby_swallow',
	signature = '',
	alias = 'CDLCONCEALBABYSWALL',
	agnostic = FALSE
)

metadata[[7]] <- list(
	title = 'Counter Attack',
	fun = 'counter_attack',
	signature = '',
	alias = 'CDLCOUNTERATTACK',
	agnostic = FALSE
)

metadata[[8]] <- list(
	title = 'Dark Cloud Cover',
	fun = 'dark_cloud_cover',
	signature = 'eps = 0',
	alias = 'CDLDARKCLOUDCOVER',
	agnostic = FALSE
)

metadata[[9]] <- list(
	title = 'Doji',
	fun = 'doji',
	signature = '',
	alias = 'CDLDOJI',
	agnostic = TRUE
)

metadata[[10]] <- list(
	title = 'Doji Star',
	fun = 'doji_star',
	signature = '',
	alias = 'CDLDOJISTAR',
	agnostic = FALSE
)

metadata[[11]] <- list(
	title = 'Dragonfly Doji',
	fun = 'dragonfly_doji',
	signature = '',
	alias = 'CDLDRAGONFLYDOJI',
	agnostic = FALSE
)

metadata[[12]] <- list(
	title = 'Engulfing',
	fun = 'engulfing',
	signature = '',
	alias = 'CDLENGULFING',
	agnostic = FALSE
)

metadata[[13]] <- list(
	title = 'Evening Doji Star',
	fun = 'evening_doji_star',
	signature = 'eps = 0',
	alias = 'CDLEVENINGDOJISTAR',
	agnostic = FALSE
)

metadata[[14]] <- list(
	title = 'Up/Down-gap side-by-side white lines',
	fun = 'gaps_side_white',
	signature = '',
	alias = 'CDLGAPSIDESIDEWHITE',
	agnostic = FALSE
)

metadata[[15]] <- list(
	title = 'Gravestone Doji',
	fun = 'gravestone_doji',
	signature = '',
	alias = 'CDLGRAVESTONEDOJI',
	agnostic = FALSE
)

metadata[[16]] <- list(
	title = 'Hammer',
	fun = 'hammer',
	signature = '',
	alias = 'CDLHAMMER',
	agnostic = FALSE
)

metadata[[17]] <- list(
	title = 'Hanging Man',
	fun = 'hanging_man',
	signature = '',
	alias = 'CDLHANGINGMAN',
	agnostic = FALSE
)

metadata[[18]] <- list(
	title = 'Harami',
	fun = 'harami',
	signature = '',
	alias = 'CDLHARAMI',
	agnostic = FALSE
)

metadata[[19]] <- list(
	title = 'Harami Cross',
	fun = 'harami_cross',
	signature = '',
	alias = 'CDLHARAMICROSS',
	agnostic = FALSE
)

metadata[[20]] <- list(
	title = 'High Wave',
	fun = 'high_wave',
	signature = '',
	alias = 'CDLHIGHWAVE',
	agnostic = TRUE
)

metadata[[21]] <- list(
	title = 'Hikkake',
	fun = 'hikakke',
	signature = '',
	alias = 'CDLHIKKAKE',
	agnostic = FALSE
)

metadata[[22]] <- list(
	title = 'Hikkake Modified',
	fun = 'hikakke_mod',
	signature = '',
	alias = 'CDLHIKKAKEMOD',
	agnostic = FALSE
)

metadata[[23]] <- list(
	title = 'Homing Pigeon',
	fun = 'homing_pigeon',
	signature = '',
	alias = 'CDLHOMINGPIGEON',
	agnostic = FALSE
)

metadata[[24]] <- list(
	title = 'In Neck',
	fun = 'in_neck',
	signature = '',
	alias = 'CDLINNECK',
	agnostic = FALSE
)

metadata[[25]] <- list(
	title = 'Inverted Hammer',
	fun = 'inverted_hammer',
	signature = '',
	alias = 'CDLINVERTEDHAMMER',
	agnostic = FALSE
)

metadata[[26]] <- list(
	title = 'Kicking',
	fun = 'kicking',
	signature = '',
	alias = 'CDLKICKING',
	agnostic = FALSE
)

metadata[[27]] <- list(
	title = 'Kicking Baby Length',
	fun = 'kicking_baby_length',
	signature = '',
	alias = 'CDLKICKINGBYLENGTH',
	agnostic = TRUE
)

metadata[[28]] <- list(
	title = 'Long Legged Doji',
	fun = 'long_legged_doji',
	signature = '',
	alias = 'CDLLONGLEGGEDDOJI',
	agnostic = TRUE
)

metadata[[29]] <- list(
	title = 'Long Line',
	fun = 'long_line',
	signature = '',
	alias = 'CDLLONGLINE',
	agnostic = TRUE
)

metadata[[30]] <- list(
	title = 'Marubozu',
	fun = 'marubozu',
	signature = '',
	alias = 'CDLMARUBOZU',
	agnostic = FALSE
)

metadata[[31]] <- list(
	title = 'Mat Hold',
	fun = 'mat_hold',
	signature = 'eps=0',
	alias = 'CDLMATHOLD',
	agnostic = FALSE
)

metadata[[32]] <- list(
	title = 'Matching Low',
	fun = 'matching_low',
	signature = '',
	alias = 'CDLMATCHINGLOW',
	agnostic = FALSE
)

metadata[[33]] <- list(
	title = 'Morning Doji Star',
	fun = 'morning_doji_star',
	signature = 'eps=0',
	alias = 'CDLMORNINGDOJISTAR',
	agnostic = FALSE
)

metadata[[34]] <- list(
	title = 'Morning Star',
	fun = 'morning_star',
	signature = 'eps = 0',
	alias = 'CDLMORNINGSTAR',
	agnostic = FALSE
)

metadata[[35]] <- list(
	title = 'On-Neck',
	fun = 'on_neck',
	signature = '',
	alias = 'CDLONNECK',
	agnostic = FALSE
)

metadata[[36]] <- list(
	title = 'Piercing',
	fun = 'piercing',
	signature = '',
	alias = 'CDLPIERCING',
	agnostic = TRUE
)

metadata[[37]] <- list(
	title = 'Rickshaw Man',
	fun = 'rickshaw_man',
	signature = '',
	alias = 'CDLRICKSHAWMAN',
	agnostic = FALSE
)

metadata[[38]] <- list(
	title = 'Rising/Falling Three Methods',
	fun = 'rise_fall_3_methods',
	signature = '',
	alias = 'CDLRISEFALL3METHODS',
	agnostic = FALSE
)

metadata[[39]] <- list(
	title = 'Separating Lines',
	fun = 'separating_lines',
	signature = '',
	alias = 'CDLSEPARATINGLINES',
	agnostic = FALSE
)

metadata[[40]] <- list(
	title = 'Shooting Star',
	fun = 'shooting_star',
	signature = '',
	alias = 'CDLSHOOTINGSTAR',
	agnostic = TRUE
)

metadata[[41]] <- list(
	title = 'Short Line Candle',
	fun = 'short_line',
	signature = '',
	alias = 'CDLSHORTLINE',
	agnostic = TRUE
)

metadata[[42]] <- list(
	title = 'Spinning Top',
	fun = 'spinning_top',
	signature = '',
	alias = 'CDLSPINNINGTOP',
	agnostic = FALSE
)

metadata[[43]] <- list(
	title = 'Stalled Pattern',
	fun = 'stalled_pattern',
	signature = '',
	alias = 'CDLSTALLEDPATTERN',
	agnostic = FALSE
)

metadata[[44]] <- list(
	title = 'Stick Sandwich',
	fun = 'stick_sandwich',
	signature = '',
	alias = 'CDLSTICKSANDWICH',
	agnostic = FALSE
)

metadata[[45]] <- list(
	title = 'Takuri',
	fun = 'takuri',
	signature = '',
	alias = 'CDLTAKURI',
	agnostic = FALSE
)

metadata[[46]] <- list(
	title = 'Tasuki Gap',
	fun = 'tasuki_gap',
	signature = '',
	alias = 'CDLTASUKIGAP',
	agnostic = FALSE
)

metadata[[47]] <- list(
	title = 'Three Black Crows',
	fun = 'three_black_crows',
	signature = '',
	alias = 'CDL3BLACKCROWS',
	agnostic = FALSE
)

metadata[[48]] <- list(
	title = 'Identical Three Crows',
	fun = 'three_identical_crows',
	signature = '',
	alias = 'CDLIDENTICAL3CROWS',
	agnostic = FALSE
)

metadata[[49]] <- list(
	title = 'Three Inside',
	fun = 'three_inside',
	signature = '',
	alias = 'CDL3INSIDE',
	agnostic = FALSE
)

metadata[[50]] <- list(
	title = 'Three-Line Strike',
	fun = 'three_line_strike',
	signature = '',
	alias = 'CDL3LINESTRIKE',
	agnostic = FALSE
)

metadata[[51]] <- list(
	title = 'Three Outside',
	fun = 'three_outside',
	signature = '',
	alias = 'CDL3OUTSIDE',
	agnostic = FALSE
)

metadata[[52]] <- list(
	title = 'Three Stars in the South',
	fun = 'three_stars_in_the_south',
	signature = '',
	alias = 'CDL3STARSINSOUTH',
	agnostic = FALSE
)

metadata[[53]] <- list(
	title = 'Three White Soldiers',
	fun = 'three_white_soldiers',
	signature = '',
	alias = 'CDL3WHITESOLDIERS',
	agnostic = FALSE
)

metadata[[54]] <- list(
	title = 'Thrusting',
	fun = 'thrusting',
	signature = '',
	alias = 'CDLTHRUSTING',
	agnostic = FALSE
)

metadata[[55]] <- list(
	title = 'Tristar',
	fun = 'tristar',
	signature = '',
	alias = 'CDLTRISTAR',
	agnostic = FALSE
)

metadata[[56]] <- list(
	title = 'Two Crows',
	fun = 'two_crows',
	signature = '',
	alias = 'CDL2CROWS',
	agnostic = FALSE
)

metadata[[57]] <- list(
	title = 'Unique Three River',
	fun = 'unique_3_river',
	signature = '',
	alias = 'CDLUNIQUE3RIVER',
	agnostic = FALSE
)

metadata[[58]] <- list(
	title = 'Upside Gap Two Crows',
	fun = 'upside_gap_2_crows',
	signature = '',
	alias = 'CDLUPSIDEGAP2CROWS',
	agnostic = FALSE
)

metadata[[59]] <- list(
	title = 'Upside/Downside Gap Three Methods',
	fun = 'xside_gap_3_methods',
	signature = '',
	alias = 'CDLXSIDEGAP3METHODS',
	agnostic = FALSE
)

metadata[[60]] <- list(
	title = 'Ladder Bottom',
	fun = 'ladder_bottom',
	signature = '',
	alias = 'CDLLADDERBOTTOM',
	agnostic = FALSE
)

metadata[[61]] <- list(
	title = 'Evening Star',
	fun = 'evening_star',
	signature = 'eps = 0',
	alias = 'CDLEVENINGSTAR',
	agnostic = FALSE
)

## 2) generate a wrapper that
##    that accepts a list
source("tools/generators/generate_functions.R")

generate <- function(
	x
) {
	generate_candlestick(
		title = x$title,
		fun = x$fun,
		signature = x$signature,
		alias = x$alias,
		agnostic = x$agnostic
	)
}

## 3) execute algorithm
##    and celebrate
for (x in metadata) {
	generate(
		x
	)
}

## 4) generate candlestick C files
for (x in metadata) {
	system2(
		command = "bash",
		args = c(
			"tools/generate_candlestick.sh",
			shQuote(x$alias),
			shQuote(x$signature)
		)
	)
}
