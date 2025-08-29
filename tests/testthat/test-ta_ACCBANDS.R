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
})
