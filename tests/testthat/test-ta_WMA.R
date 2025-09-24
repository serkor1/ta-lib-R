## script: Weighted Moving Average
## author: Serkan Korkmaz
testthat::test_that(desc = "Weighted Moving Average", code = {
	## 1) calculate values
	##    with and without alias
	output <- weighted_moving_average(SPY)
	alias <- WMA(SPY)

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
			indicator(weighted_moving_average)
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
		inherits(weighted_moving_average(SPY), class(SPY))
	)

	## 3.2) data.frame
	testthat::expect_true(
		inherits(weighted_moving_average(BTC), class(BTC))
	)

	## 3.3) vectors
	testthat::expect_true(
		is.vector(weighted_moving_average(BTC[, 1]))
	)

	## 4) test that default
	##    values equals
	testthat::expect_equal(
		object = weighted_moving_average(
			BTC
		),
		expected = weighted_moving_average(
			BTC,
			cols = ~open
		)
	)
})
