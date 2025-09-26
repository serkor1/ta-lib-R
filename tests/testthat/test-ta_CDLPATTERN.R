## script: CDLPATTERN
## objective:
##
## Test all candlestick patterns
## and their aliases
##
## 1) list all candlestick
##    functions and their
##    aliases
candlestick_patterns <- list(
	CDL2CROWS = list(
		CDL2CROWS,
		two_crows
	),
	CDL3BLACKCROWS = list(
		CDL3BLACKCROWS,
		three_black_crows
	),
	CDL3INSIDE = list(
		CDL3INSIDE,
		three_inside
	),
	CDL3LINESTRIKE = list(
		CDL3LINESTRIKE,
		three_line_strike
	),
	CDL3OUTSIDE = list(
		CDL3OUTSIDE,
		three_outside
	),
	CDL3STARSINSOUTH = list(
		CDL3STARSINSOUTH,
		three_stars_in_the_south
	),
	CDLABANDONEDBABY = list(
		CDLABANDONEDBABY,
		abandoned_baby
	),
	CDLADVANCEBLOCK = list(
		CDLADVANCEBLOCK,
		advance_block
	),
	CDLBABYSWALL = list(
		CDLBABYSWALL,
		concealing_baby_swallow
	),
	CDLBELTHOLD = list(
		CDLBELTHOLD,
		belt_hold
	),
	CDLBREAKAWAY = list(
		CDLBREAKAWAY,
		break_away
	),
	CDLCOUNTERATTACK = list(
		CDLCOUNTERATTACK,
		counter_attack
	),
	CDLDARKCLOUDCOVER = list(
		CDLDARKCLOUDCOVER,
		dark_cloud_cover
	),
	CDLDOJI = list(
		CDLDOJI,
		doji
	),
	CDLDOJISTAR = list(
		CDLDOJISTAR,
		doji_star
	),
	CDLDRAGONFLYDOJI = list(
		CDLDRAGONFLYDOJI,
		dragonfly_doji
	),
	CDLENGULFING = list(
		CDLENGULFING,
		engulfing
	),
	CDLEVENINGDOJISTAR = list(
		CDLEVENINGDOJISTAR,
		evening_doji_star
	),
	CDLGAPSIDESIDEWHITE = list(
		CDLGAPSIDESIDEWHITE,
		gaps_side_white
	),
	CDLGRAVESTONEDOJI = list(
		CDLGRAVESTONEDOJI,
		gravestone_doji
	),
	CDLHAMMER = list(
		CDLHAMMER,
		hammer
	),
	CDLHANGINGMAN = list(
		CDLHANGINGMAN,
		hanging_man
	)
)

## conduct the tests
testthat::test_that(desc = "Candlestick Patterns", code = {
	## test all functions
	for (test_pattern in names(candlestick_patterns)) {
		## 1) calculate values
		##    with and without alias
		output <- candlestick_patterns[[test_pattern]][[2]](SPY)
		alias <- candlestick_patterns[[test_pattern]][[1]](SPY)

		## 1.1) check if the values
		##      are equal
		testthat::expect_equal(
			object = output,
			expected = alias,
			label = test_pattern
		)

		## 2) test that charting
		##    works
		output <- testthat::expect_no_error(
			{
				chart(BTC)
				indicator(candlestick_patterns[[test_pattern]][[2]])
			}
		)

		## 2.1) test that it outputs
		##      a plotly object
		testthat::expect_true(
			inherits(output, "plotly"),
			label = test_pattern
		)

		## 3) test class-in and class-out
		##    equality

		## 3.1) matrix
		testthat::expect_true(
			inherits(
				candlestick_patterns[[test_pattern]][[2]](SPY),
				class(SPY)
			),
			label = test_pattern
		)

		## 3.2) data.frame
		testthat::expect_true(
			inherits(
				candlestick_patterns[[test_pattern]][[2]](BTC),
				class(BTC)
			),
			label = test_pattern
		)

		## 4) test that default
		##    values equals
		testthat::expect_equal(
			object = candlestick_patterns[[test_pattern]][[2]](
				BTC
			),
			expected = candlestick_patterns[[test_pattern]][[2]](
				BTC,
				cols = ~ open + high + low + close
			),
			label = test_pattern
		)
	}
})
