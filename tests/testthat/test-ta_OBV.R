## script: OBV
## author: Serkan Korkmaz
testthat::test_that(desc = "On-Balance Volume", code = {
	## 1) calculate values
	##    with and without alias
	output <- on_balance_volume(SPY)
	alias <- OBV(SPY)

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
			indicator(on_balance_volume())
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
		inherits(on_balance_volume(SPY), class(SPY))
	)

	## 3.2) data.frame
	testthat::expect_true(
		inherits(on_balance_volume(BTC), class(BTC))
	)

	## 4) test that default
	##    values equals
	testthat::expect_equal(
		object = on_balance_volume(
			BTC
		),
		expected = on_balance_volume(
			BTC,
			cols = ~ close + volume
		)
	)
})
