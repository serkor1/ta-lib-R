## script: ACCBANDS
## author: Serkan Korkmaz
testthat::test_that(desc = "Acceleration Bands", code = {
	## 1) calculate values
	##    with and without alias
	output <- acceleration_bands(SPY)
	alias <- ACCBANDS(SPY)

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
			indicator(acceleration_bands())
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
		inherits(acceleration_bands(SPY), class(SPY))
	)

	## 3.2) data.frame
	testthat::expect_true(
		inherits(acceleration_bands(BTC), class(BTC))
	)

	## 4) test that default
	##    values equals
	testthat::expect_equal(
		object = acceleration_bands(
			BTC
		),
		expected = acceleration_bands(
			BTC,
			cols = ~ open + high + close
		)
	)
})
