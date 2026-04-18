## tests for the formula-based column selector
## series() is internal; we exercise it via the indicator pipeline

series <- talib:::series

testthat::test_that("series() requires data via ...", {
	testthat::expect_error(
		series(x = ~close, default = ~close),
		"data"
	)
})

testthat::test_that("series() falls back to default formula when x is missing", {
	df <- data.frame(close = 1:5)
	out <- series(default = ~close, data = df)

	testthat::expect_s3_class(out, "data.frame")
	testthat::expect_equal(out$close, 1:5)
})

testthat::test_that("series() honours explicit formula over default", {
	df <- data.frame(close = 1:5, open = 6:10)
	out <- series(x = ~open, default = ~close, data = df)

	testthat::expect_equal(names(out)[1L], "open")
})

testthat::test_that("series() rejects shorter formula than default", {
	df <- data.frame(close = 1:5, high = 6:10, low = 11:15)

	## default expects 3 vars - we pass 1
	testthat::expect_error(
		series(x = ~close, default = ~ high + low + close, data = df)
	)
})

testthat::test_that("series() errors on unknown column", {
	df <- data.frame(close = 1:5)

	testthat::expect_error(
		series(x = ~missing_col, default = ~close, data = df)
	)
})

testthat::test_that("series() coerces non-data.frame to data.frame", {
	mat <- matrix(1:10, ncol = 2, dimnames = list(NULL, c("close", "open")))

	testthat::expect_no_error(
		out <- series(default = ~close, data = mat)
	)
	testthat::expect_s3_class(out, "data.frame")
})
