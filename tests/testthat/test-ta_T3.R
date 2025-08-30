## script: T3 Moving Average (T3)
## author: Serkan Korkmaz
testthat::test_that(desc = "T3 Moving Average (T3)", code = {
	## 1) calculate values
	##    with and without alias
	output <- T3_moving_average(SPY)
	alias <- T3(SPY)

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
			indicator(T3_moving_average())
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
		inherits(T3_moving_average(SPY), class(SPY))
	)

	## 3.2) data.frame
	testthat::expect_true(
		inherits(T3_moving_average(BTC), class(BTC))
	)

	## 3.3) vectors
	testthat::expect_true(
		is.vector(T3_moving_average(BTC[, 1]))
	)

	## 4) test that default
	##    values equals
	testthat::expect_equal(
		object = T3_moving_average(
			BTC
		),
		expected = T3_moving_average(
			BTC,
			cols = ~open
		)
	)
})
