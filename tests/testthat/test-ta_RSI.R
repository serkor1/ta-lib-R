## script: Relative Strength Index
## author: Serkan Korkmaz
testthat::test_that(desc = "Relative Strength Index", code = {
	## 1) calculate values
	##    with and without alias
	output <- relative_strength_index(SPY)
	alias <- RSI(SPY)

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
			indicator(relative_strength_index())
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
		inherits(relative_strength_index(SPY), class(SPY))
	)

	## 3.2) data.frame
	testthat::expect_true(
		inherits(relative_strength_index(BTC), class(BTC))
	)

	## 3.3) vectors
	testthat::expect_true(
		is.vector(relative_strength_index(BTC[, 1]))
	)

	## 4) test that default
	##    values equals
	testthat::expect_equal(
		object = relative_strength_index(
			BTC
		),
		expected = relative_strength_index(
			BTC,
			cols = ~open
		)
	)
})
