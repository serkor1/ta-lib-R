## script: SAR
## author: Serkan Korkmaz
testthat::test_that(desc = "Parabolic SAR", code = {
	## 1) calculate values
	##    with and without alias
	output <- parabolic_sar(SPY)
	alias <- SAR(SPY)

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
			indicator(parabolic_sar)
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
		inherits(parabolic_sar(SPY), class(SPY))
	)

	## 3.2) data.frame
	testthat::expect_true(
		inherits(parabolic_sar(BTC), class(BTC))
	)

	## 4) test that default
	##    values equals
	testthat::expect_equal(
		object = parabolic_sar(
			BTC
		),
		expected = parabolic_sar(
			BTC,
			cols = ~ high + low
		)
	)
})
