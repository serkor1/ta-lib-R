## script: MFI
## author: Serkan Korkmaz
testthat::test_that(desc = "Money Flow Index", code = {
	## 1) calculate values
	##    with and without alias
	output <- money_flow_index(SPY)
	alias <- MFI(SPY)

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
			indicator(money_flow_index)
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
		inherits(money_flow_index(SPY), class(SPY))
	)

	## 3.2) data.frame
	testthat::expect_true(
		inherits(money_flow_index(BTC), class(BTC))
	)

	## 4) test that default
	##    values equals
	testthat::expect_equal(
		object = money_flow_index(
			BTC
		),
		expected = money_flow_index(
			BTC,
			cols = ~ high + low + close + volume
		)
	)
})
