## script: CMO
## author: Serkan Korkmaz
testthat::test_that(desc = "Chande Momentum Indicator", code = {
	## 1) calculate values
	##    with and without alias
	output <- chande_momentum_oscillator(SPY)
	alias <- CMO(SPY)

	## 1.1) check if the values
	##      are equal
	testthat::expect_equal(
		object = output,
		expected = alias
	)

	## 2) test that charting
	##    works
	output <- testthat::expect_no_error(
		{
			chart(BTC)
			indicator(chande_momentum_oscillator())
		}
	)

	## 2.1) test that it outputs
	##      a plotly object
	testthat::expect_true(
		inherits(output, "plotly")
	)

	## 3) test class-in and class-out
	##    equality

	## 3.1) matrix
	testthat::expect_true(
		inherits(chande_momentum_oscillator(SPY), class(SPY))
	)

	## 3.2) data.frame
	testthat::expect_true(
		inherits(chande_momentum_oscillator(BTC), class(BTC))
	)

	## 4) test that default
	##    values equals
	testthat::expect_equal(
		object = chande_momentum_oscillator(
			BTC
		),
		expected = chande_momentum_oscillator(
			BTC,
			cols = ~open
		)
	)
})
