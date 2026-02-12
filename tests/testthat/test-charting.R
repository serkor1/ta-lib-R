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

## test charting with themes
testthat::test_that(desc = "Charting with Themes", code = {
	## 1) test chart with set_theme()
	testthat::expect_no_error(
		{
			set_theme$hawks_and_doves()
			chart(SPY)
		}
	)

	testthat::expect_no_error(
		{
			set_theme$payout()
			chart(SPY)
		}
	)

	testthat::expect_no_error(
		{
			set_theme$tp_slapped()
			chart(SPY)
		}
	)

	testthat::expect_no_error(
		{
			set_theme$trust_the_process()
			chart(SPY)
		}
	)
})
