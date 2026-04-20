## Unified indicator metadata
##
## All indicator definitions in one place.
## Each entry feeds into generate.R which calls
## impl_generate_indicator(), impl_generate_test(),
## and the appropriate C generator.
##
## Fields:
##   title       - Human-readable indicator name
##   fun         - R function name (snake_case)
##   alias       - TA-Lib alias / uppercase short name
##   family      - Category for roxygen2 grouping
##   formula     - Default column formula (default: "~close")
##   signature   - Character vector of function arguments (default: NULL = none)
##   subchart    - 0 = main chart overlay, 1 = subchart (default: 1)
##   plotly      - Append plotly template to R wrapper? (default: 1)
##   test_plotly - Test plotly/ggplot methods? (default: inherits plotly)
##   candlestick - Use candlestick template? (default: 0)
##   agnostic    - OHLC order agnostic? (default: NULL)
##   maType      - Moving average type index (default: -1 = not MA)
##   rolling     - Use rolling template? (default: 0)
##   univariate  - Force univariate numeric method? (default: NULL)
##   c_generator - C generation strategy:
##                 NULL      = standard (generate_indicator_core.sh → stdout)
##                 "candlestick" = generate_core_candlestick.sh
##                 "skip"        = do not generate C

## -----------------------------------------------------------
## Constructor helpers — set per-family defaults so each
## entry only specifies what differs.
## -----------------------------------------------------------

momentum <- function(
	title, fun, alias, formula, signature,
	subchart = 1L, c_generator = NULL
) {
	list(
		title = title, fun = fun, alias = alias,
		family = "Momentum Indicator",
		formula = formula, signature = signature,
		subchart = subchart, c_generator = c_generator
	)
}

candlestick <- function(title, fun, alias, signature = "", agnostic = FALSE) {
	list(
		title = title, fun = fun, alias = alias,
		family = "Pattern Recognition",
		formula = "~open + high + low + close",
		signature = signature,
		candlestick = 1, plotly = 0, test_plotly = 1,
		c_generator = "candlestick",
		agnostic = agnostic
	)
}

moving_avg <- function(title, fun, alias, ma_type, n_default = 30L, signature = NULL) {
	if (is.null(signature)) {
		signature <- sprintf("n=%d", as.integer(n_default))
	}
	list(
		title = title, fun = fun, alias = alias,
		family = "Overlap Study",
		formula = "~close",
		maType = ma_type,
		n_default = as.integer(n_default),
		signature = signature,
		plotly = 0, test_plotly = 1,
		univariate = 0, # MA template has built-in numeric method
		c_generator = NULL
	)
}

overlap <- function(title, fun, alias, formula, signature, subchart = 0L) {
	list(
		title = title, fun = fun, alias = alias,
		family = "Overlap Study",
		formula = formula, signature = signature,
		subchart = subchart
	)
}

cycle <- function(title, fun, alias, subchart = 1L) {
	list(
		title = title, fun = fun, alias = alias,
		family = "Cycle Indicator",
		formula = "~close",
		subchart = subchart
	)
}

price_xform <- function(title, fun, alias, formula, signature = NULL) {
	list(
		title = title, fun = fun, alias = alias,
		family = "Price Transform",
		formula = formula, signature = signature,
		plotly = 0, rolling = 0
	)
}

volume <- function(
	title, fun, alias, formula, signature = "",
	subchart = 1L, univariate = NULL, c_generator = NULL
) {
	list(
		title = title, fun = fun, alias = alias,
		family = "Volume Indicator",
		formula = formula, signature = signature,
		subchart = subchart, univariate = univariate,
		c_generator = c_generator
	)
}

volatility <- function(title, fun, alias, formula, signature = "", subchart = 1L) {
	list(
		title = title, fun = fun, alias = alias,
		family = "Volatility Indicator",
		formula = formula, signature = signature,
		subchart = subchart
	)
}

rolling <- function(title, fun, alias, signature) {
	list(
		title = title, fun = fun, alias = alias,
		family = "Rolling Statistic",
		plotly = 0, rolling = 1,
		signature = signature
	)
}


## -----------------------------------------------------------
## Indicator metadata
## -----------------------------------------------------------

indicators <- list(

	## ========================
	## Cycle Indicators
	## ========================
	cycle("Hilbert Transform - Dominant Cycle Period", "dominant_cycle_period", "HT_DCPERIOD"),
	cycle("Hilbert Transform - Dominant Cycle Phase", "dominant_cycle_phase", "HT_DCPHASE"),
	cycle("Hilbert Transform - Phasor Components", "phasor_components", "HT_PHASOR"),
	cycle("Hilbert Transform - SineWave", "sine_wave", "HT_SINE"),
	cycle("Hilbert Transform - Trend vs Cycle Mode", "trend_cycle_mode", "HT_TRENDMODE"),

	## ========================
	## Candlestick Patterns
	## ========================
	candlestick("Abandoned Baby", "abandoned_baby", "CDLABANDONEDBABY", signature = "eps = 0"),
	candlestick("Advance Block", "advance_block", "CDLADVANCEBLOCK"),
	candlestick("Belt Hold", "belt_hold", "CDLBELTHOLD"),
	candlestick("Break Away", "break_away", "CDLBREAKAWAY"),
	candlestick("Closing Marubozu", "closing_marubozu", "CDLCLOSINGMARUBOZU", agnostic = TRUE),
	candlestick("Concealing Baby Swallow", "concealing_baby_swallow", "CDLCONCEALBABYSWALL"),
	candlestick("Counter Attack", "counter_attack", "CDLCOUNTERATTACK"),
	candlestick("Dark Cloud Cover", "dark_cloud_cover", "CDLDARKCLOUDCOVER", signature = "eps = 0"),
	candlestick("Doji", "doji", "CDLDOJI", agnostic = TRUE),
	candlestick("Doji Star", "doji_star", "CDLDOJISTAR"),
	candlestick("Dragonfly Doji", "dragonfly_doji", "CDLDRAGONFLYDOJI"),
	candlestick("Engulfing", "engulfing", "CDLENGULFING"),
	candlestick("Evening Doji Star", "evening_doji_star", "CDLEVENINGDOJISTAR", signature = "eps = 0"),
	candlestick("Up/Down-gap side-by-side white lines", "gaps_side_white", "CDLGAPSIDESIDEWHITE"),
	candlestick("Gravestone Doji", "gravestone_doji", "CDLGRAVESTONEDOJI"),
	candlestick("Hammer", "hammer", "CDLHAMMER"),
	candlestick("Hanging Man", "hanging_man", "CDLHANGINGMAN"),
	candlestick("Harami", "harami", "CDLHARAMI"),
	candlestick("Harami Cross", "harami_cross", "CDLHARAMICROSS"),
	candlestick("High Wave", "high_wave", "CDLHIGHWAVE", agnostic = TRUE),
	candlestick("Hikkake", "hikakke", "CDLHIKKAKE"),
	candlestick("Hikkake Modified", "hikakke_mod", "CDLHIKKAKEMOD"),
	candlestick("Homing Pigeon", "homing_pigeon", "CDLHOMINGPIGEON"),
	candlestick("In Neck", "in_neck", "CDLINNECK"),
	candlestick("Inverted Hammer", "inverted_hammer", "CDLINVERTEDHAMMER"),
	candlestick("Kicking", "kicking", "CDLKICKING"),
	candlestick("Kicking Baby Length", "kicking_baby_length", "CDLKICKINGBYLENGTH", agnostic = TRUE),
	candlestick("Long Legged Doji", "long_legged_doji", "CDLLONGLEGGEDDOJI", agnostic = TRUE),
	candlestick("Long Line", "long_line", "CDLLONGLINE", agnostic = TRUE),
	candlestick("Marubozu", "marubozu", "CDLMARUBOZU"),
	candlestick("Mat Hold", "mat_hold", "CDLMATHOLD", signature = "eps=0"),
	candlestick("Matching Low", "matching_low", "CDLMATCHINGLOW"),
	candlestick("Morning Doji Star", "morning_doji_star", "CDLMORNINGDOJISTAR", signature = "eps=0"),
	candlestick("Morning Star", "morning_star", "CDLMORNINGSTAR", signature = "eps = 0"),
	candlestick("On-Neck", "on_neck", "CDLONNECK"),
	candlestick("Piercing", "piercing", "CDLPIERCING", agnostic = TRUE),
	candlestick("Rickshaw Man", "rickshaw_man", "CDLRICKSHAWMAN"),
	candlestick("Rising/Falling Three Methods", "rise_fall_3_methods", "CDLRISEFALL3METHODS"),
	candlestick("Separating Lines", "separating_lines", "CDLSEPARATINGLINES"),
	candlestick("Shooting Star", "shooting_star", "CDLSHOOTINGSTAR", agnostic = TRUE),
	candlestick("Short Line Candle", "short_line", "CDLSHORTLINE", agnostic = TRUE),
	candlestick("Spinning Top", "spinning_top", "CDLSPINNINGTOP"),
	candlestick("Stalled Pattern", "stalled_pattern", "CDLSTALLEDPATTERN"),
	candlestick("Stick Sandwich", "stick_sandwich", "CDLSTICKSANDWICH"),
	candlestick("Takuri", "takuri", "CDLTAKURI"),
	candlestick("Tasuki Gap", "tasuki_gap", "CDLTASUKIGAP"),
	candlestick("Three Black Crows", "three_black_crows", "CDL3BLACKCROWS"),
	candlestick("Identical Three Crows", "three_identical_crows", "CDLIDENTICAL3CROWS"),
	candlestick("Three Inside", "three_inside", "CDL3INSIDE"),
	candlestick("Three-Line Strike", "three_line_strike", "CDL3LINESTRIKE"),
	candlestick("Three Outside", "three_outside", "CDL3OUTSIDE"),
	candlestick("Three Stars in the South", "three_stars_in_the_south", "CDL3STARSINSOUTH"),
	candlestick("Three White Soldiers", "three_white_soldiers", "CDL3WHITESOLDIERS"),
	candlestick("Thrusting", "thrusting", "CDLTHRUSTING"),
	candlestick("Tristar", "tristar", "CDLTRISTAR"),
	candlestick("Two Crows", "two_crows", "CDL2CROWS"),
	candlestick("Unique Three River", "unique_3_river", "CDLUNIQUE3RIVER"),
	candlestick("Upside Gap Two Crows", "upside_gap_2_crows", "CDLUPSIDEGAP2CROWS"),
	candlestick("Upside/Downside Gap Three Methods", "xside_gap_3_methods", "CDLXSIDEGAP3METHODS"),
	candlestick("Ladder Bottom", "ladder_bottom", "CDLLADDERBOTTOM"),
	candlestick("Evening Star", "evening_star", "CDLEVENINGSTAR", signature = "eps = 0"),

	## ========================
	## Momentum Indicators
	## ========================
	momentum("Aroon", "aroon", "AROON", "~ high + low", c("n=14")),
	momentum("Aroon Oscillator", "aroon_oscillator", "AROONOSC", "~ high + low", c("n=14")),
	momentum("Chande Momentum Oscillator", "chande_momentum_oscillator", "CMO", "~ close", c("n=14")),
	momentum("Commodity Channel Index", "commodity_channel_index", "CCI", "~ high + low + close", c("n=14"), subchart = 0L),
	momentum("Fast Stochastic", "fast_stochastic", "STOCHF", "~ high + low + close", c("fastk=5", "fastd=SMA(n=3)")),
	momentum("Money Flow Index", "money_flow_index", "MFI", "~ high + low + close + volume", c("n = 14")),
	momentum("Moving Average Convergence Divergence", "moving_average_convergence_divergence", "MACD", "~close", c("fast = 12", "slow = 26", "signal = 9")),
	momentum("Moving Average Convergence Divergence (Extended)", "extended_moving_average_convergence_divergence", "MACDEXT", "~close", c("fast = SMA(n = 12)", "slow = SMA(n = 26)", "signal = SMA(n = 9)")),
	momentum("Moving Average Convergence Divergence (Fixed)", "fixed_moving_average_convergence_divergence", "MACDFIX", "~close", c("signal=9")),
	momentum("Relative Strength Index", "relative_strength_index", "RSI", "~close", c("n=14")),
	momentum("Stochastic", "stochastic", "STOCH", "~ high + low + close", c("fastk = 5", "slowk = SMA(n = 3)", "slowd = SMA(n = 3)")),
	momentum("Stochastic Relative Strength Index", "stochastic_relative_strength_index", "STOCHRSI", "~close", c("n=14", "fastk=5", "fastd=SMA(n=3)")),
	momentum("Ultimate Oscillator", "ultimate_oscillator", "ULTOSC", "~ high + low + close", c("n=c(7, 14, 28)")),
	momentum("Average Directional Movement Index", "average_directional_movement_index", "ADX", "~ high + low + close", c("n=14")),
	momentum("Average Directional Movement Index Rating", "average_directional_movement_index_rating", "ADXR", "~ high + low + close", c("n=14")),
	momentum("Balance of Power", "balance_of_power", "BOP", "~ open + high + low + close", c(character(0))),
	momentum("Momentum", "momentum", "MOM", "~ close", c("n=10")),
	momentum("Williams %R", "williams_oscillator", "WILLR", "~ high + low + close", c("n=14")),
	momentum("Percentage Price Oscillator", "percentage_price_oscillator", "PPO", "~close", c("fast=12", "slow=26", "ma=SMA(n=9)")),
	momentum("Triple Exponential Average", "triple_exponential_average", "TRIX", "~close", c("n=30")),
	momentum("Directional Movement Index", "directional_movement_index", "DX", "~high + low + close", c("n=14")),
	momentum("Intraday Movement Index", "intraday_movement_index", "IMI", "~open + close", c("n=14")),
	momentum("Minus Directional Indicator", "minus_directional_indicator", "MINUS_DI", "~high + low + close", c("n=14")),
	momentum("Minus Directional Movement", "minus_directional_movement", "MINUS_DM", "~high + low", c("n=14")),
	momentum("Plus Directional Indicator", "plus_directional_indicator", "PLUS_DI", "~high + low + close", c("n=14")),
	momentum("Plus Directional Movement", "plus_directional_movement", "PLUS_DM", "~high + low", c("n=14")),
	momentum("Rate of Change", "rate_of_change", "ROC", "~close", c("n=10")),
	momentum("Ratio of Change", "ratio_of_change", "ROCR", "~close", c("n=10")),
	momentum("Absolute Price Oscillator", "absolute_price_oscillator", "APO", "~close", c("fast=12", "slow=26", "ma=SMA(n=9)")),

	## ========================
	## Moving Averages
	## ========================
	moving_avg("Simple Moving Average", "simple_moving_average", "SMA", "0L"),
	moving_avg("Exponential Moving Average", "exponential_moving_average", "EMA", "1L"),
	moving_avg("Weighted Moving Average", "weighted_moving_average", "WMA", "2L"),
	moving_avg("Double Exponential Moving Average", "double_exponential_moving_average", "DEMA", "3L"),
	moving_avg("Triple Exponential Moving Average", "triple_exponential_moving_average", "TEMA", "4L"),
	moving_avg("Triangular Moving Average", "triangular_moving_average", "TRIMA", "5L"),
	moving_avg("Kaufman Adaptive Moving Average", "kaufman_adaptive_moving_average", "KAMA", "6L"),
	moving_avg(
		"MESA Adaptive Moving Average", "mesa_adaptive_moving_average", "MAMA", "7L",
		signature = c("fast=0.5", "slow=0.05")
	),
	moving_avg(
		"Triple Exponential Moving Average (T3)", "t3_exponential_moving_average", "T3", "8L",
		n_default = 5L,
		signature = c("n=5", "vfactor=0.7")
	),

	## ========================
	## Overlap Studies
	## ========================
	overlap("Bollinger Bands", "bollinger_bands", "BBANDS", "~close", c("ma=SMA(n=5)", "sd=2", "sd_down", "sd_up")),
	overlap("Hilbert Transform - Instantaneous Trendline", "trendline", "HT_TRENDLINE", "~close", ""),
	overlap("Parabolic Stop and Reverse (SAR)", "parabolic_stop_and_reverse", "SAR", "~high+low", c("acceleration=0.02", "maximum=0.2")),
	overlap("Parabolic Stop and Reverse (SAR) - Extended", "extended_parabolic_stop_and_reverse", "SAREXT", "~high+low", c("init=0", "offset=0", "init_long=0.02", "long=0.02", "max_long=0.2", "init_short=0.02", "short=0.02", "max_short=0.2")),
	overlap("Acceleration Bands", "acceleration_bands", "ACCBANDS", "~ high + low + close", c("n=20")),

	## ========================
	## Volume Indicators
	## ========================
	volume("Chaikin A/D Line", "chaikin_accumulation_distribution_line", "AD", "~high+low+close+volume"),
	volume("Chaikin A/D Oscillator", "chaikin_accumulation_distribution_oscillator", "ADOSC", "~high+low+close+volume", signature = c("fast=3", "slow=10")),
	volume("On-Balance Volume", "on_balance_volume", "OBV", "~close+volume"),
	volume("Trading Volume", "trading_volume", "VOLUME", "~volume + open + close", signature = c("ma = list(SMA(n = 7), SMA(n = 15))"), univariate = 1, c_generator = "skip"),

	## ========================
	## Volatility Indicators
	## ========================
	volatility("True Range", "true_range", "TRANGE", "~high + low + close"),
	volatility("Average True Range", "average_true_range", "ATR", "~high + low + close", signature = "n=14"),
	volatility("Normalized Average True Range", "normalized_average_true_range", "NATR", "~high + low + close", signature = "n=14"),

	## ========================
	## Price Transforms
	## ========================
	price_xform("Average Price", "average_price", "AVGPRICE", "~open + high + low + close"),
	price_xform("Median Price", "median_price", "MEDPRICE", "~high + low"),
	price_xform("Typical Price", "typical_price", "TYPPRICE", "~high + low + close"),
	price_xform("Weighted Close Price", "weighted_close_price", "WCLPRICE", "~high + low + close"),
	price_xform("Midpoint Price", "midpoint_price", "MIDPRICE", "~high + low", signature = c("n=14")),

	## ========================
	## Rolling Statistics
	## ========================
	rolling("Rolling Sum", "rolling_sum", "SUM", "n = 30"),
	rolling("Rolling Standard Deviation", "rolling_standard_deviation", "STDDEV", c("n=5", "k = 1")),
	rolling("Rolling Standard Deviation", "rolling_variance", "VAR", c("n=5", "k = 1")),
	rolling("Rolling Beta", "rolling_beta", "BETA", c("y", "n=5")),
	rolling("Rolling Correlation", "rolling_correlation", "CORREL", c("y", "n=30")),
	rolling("Rolling Max", "rolling_max", "MAX", c("n=30")),
	rolling("Rolling Min", "rolling_min", "MIN", c("n=30"))
)
