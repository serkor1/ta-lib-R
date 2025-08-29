## script: ta_BBANDS
## author: Serkan Korkmaz
testthat::test_that(desc = "Bollinger Bands", code = {
	## 1) calculate values
	##    with and without alias
	output <- bollinger_bands(SPY)
	alias <- BBANDS(SPY)

	## 1.1) check if the values
	##      are equal
	testthat::expect_equal(
		object = output,
		expected = alias
	)
})
