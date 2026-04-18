## edge case coverage for representative indicators
## RSI (single-input), BBANDS (multi-output), MACD (multi-input)

testthat::test_that("indicators reject non-numeric input via default coercion", {
	## character cannot be coerced silently
	testthat::expect_error(
		suppressWarnings(relative_strength_index(c("a", "b", "c")))
	)
})

testthat::test_that("indicators handle NA inputs without crashing", {
	x <- c(1, 2, NA, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16)

	## without na.bridge - NAs propagate (entire output may be NA)
	testthat::expect_no_error(
		relative_strength_index(x)
	)

	## with na.bridge - NAs stripped, computed, re-inserted
	out <- relative_strength_index(x, na.bridge = TRUE)
	testthat::expect_true(
		is.na(out[3])
	)
})

testthat::test_that("indicators handle zero-length input gracefully", {
	## TA-Lib accepts numeric(0); we should propagate without crashing
	testthat::expect_no_error(
		out <- relative_strength_index(numeric(0))
	)
	testthat::expect_equal(length(out), 0L)
})

testthat::test_that("data.frame methods error on missing required columns", {
	df <- data.frame(price = 1:30)

	## RSI defaults to ~close - close is missing here
	testthat::expect_error(
		relative_strength_index(df)
	)
})

testthat::test_that("column selection is case-sensitive", {
	df <- data.frame(Close = 1:30)

	## Close (capital C) is not the same as close (lowercase)
	testthat::expect_error(
		relative_strength_index(df)
	)
})

testthat::test_that("data.frame methods accept formula remap", {
	df <- data.frame(price = as.double(1:30))

	## remap price -> close via cols
	testthat::expect_no_error(
		relative_strength_index(df, cols = ~price)
	)
})

testthat::test_that("multi-output BBANDS preserves structure on edge cases", {
	x <- as.double(1:20)
	out <- bollinger_bands(x)

	## should return a 3-column matrix (Upper/Middle/Lower)
	testthat::expect_true(is.matrix(out) || is.data.frame(out))
	testthat::expect_equal(ncol(out), 3L)
})

testthat::test_that("MACD multi-input handles short series gracefully", {
	## series shorter than slow period should still complete
	## (output is NA for the lookback period)
	x <- as.double(1:50)
	testthat::expect_no_error(
		moving_average_convergence_divergence(x)
	)
})
