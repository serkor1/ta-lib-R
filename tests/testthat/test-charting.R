## script: Test charting
## author: Serkan Korkmaz
testthat::test_that(desc = "Charting", code = {
	## 1) test chart() works
	##    without issues
	##
	## 1.1) matrix
	testthat::expect_no_error(
		{
			chart(SPY)
		}
	)

	## 1.2) data.frame
	testthat::expect_no_error(
		{
			chart(SPY)
		}
	)

	## 2) test that indicators
	##    can be passed with custom
	##    data
	testthat::expect_no_error(
		{
			chart(SPY)
			indicator(
				FUN = SMA,
				cols = ~open,
				data = BTC
			)
		}
	)
})
