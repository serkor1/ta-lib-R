## 1) check that TA-Libs
##    unloads
testthat::test_that(desc = "TA-Lib unloads without error", code = {
	## 1) unload without error
	testthat::expect_no_error(
		detach("package:talib")
	)
})

## 2) check that TA-Lib
##    loads (NOTE: The order matters here because the package is already loaded when the tests are run, and gets unloaded above)
testthat::test_that(desc = "TA-Lib loads without error", code = {
	## 1) load without error
	testthat::expect_no_error(
		suppressPackageStartupMessages(
			library("talib")
		)
	)
})
