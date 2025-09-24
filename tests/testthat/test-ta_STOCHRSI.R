## script: Stochastic Relative Strength Index
## author: Serkan Korkmaz
testthat::test_that(desc = "Stochastic Relative Strength Index", code = {
	## 1) calculate values
	##    with and without alias
	output <- stochastic_relative_strength_index(RSI(SPY))
	alias <- STOCHRSI(RSI(SPY))

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
			indicator(stochastic_relative_strength_index, data = RSI(BTC))
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
		inherits(stochastic_relative_strength_index(RSI(SPY)), class(RSI(SPY)))
	)

	## 3.2) data.frame
	testthat::expect_true(
		inherits(stochastic_relative_strength_index(RSI(BTC)), class(RSI(BTC)))
	)

	## 4) test that default
	##    values equals
	testthat::expect_equal(
		object = stochastic_relative_strength_index(
			RSI(BTC)
		),
		expected = stochastic_relative_strength_index(
			RSI(BTC),
			cols = ~RSI
		)
	)
})
