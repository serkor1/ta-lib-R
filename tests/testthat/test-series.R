## tests for the formula-based column selector
## series() is internal; we exercise it via the indicator pipeline
testthat::test_that(desc = "Output is <data.frame>", code = {
	## check <matrix>
	x <- talib:::series(
		x = SPY,
		formula = ~open,
		formula.default = ~open
	)

	testthat::expect_s3_class(
		x,
		"data.frame"
	)

	## check <data.frame>
	x <- talib:::series(
		x = ATOM,
		formula = ~open,
		formula.default = ~open
	)

	testthat::expect_s3_class(
		x,
		"data.frame"
	)
})

testthat::test_that(desc = "formula has precedence over formula.default", code = {
	## check ATOM by passing
	## formula explicitly different
	## from the default
	x <- talib:::series(
		x = ATOM,
		formula = ~open,
		formula.default = ~close
	)

	## check that the colnames
	## are are open
	testthat::expect_equal(
		colnames(x),
		"open"
	)

	## check that there are no
	## implicit renaming
	testthat::expect_equal(
		x$open,
		ATOM$open
	)
})

testthat::test_that(desc = "Missing formula does not error", code = {
	## <data.frame>
	testthat::expect_no_condition(
		talib:::series(
			x = ATOM,
			formula.default = ~close
		)
	)

	## <matrix>
	testthat::expect_no_condition(
		talib:::series(
			x = SPY,
			formula.default = ~close
		)
	)
})

testthat::test_that(desc = "Attributes are respected", code = {
	## <data.frame>
	x <- talib:::series(
		x = ATOM,
		formula.default = ~ open + high + low + close + volume
	)

	testthat::expect_equal(
		x,
		ATOM
	)

	## <matrix>
	x <- talib:::series(
		x = SPY,
		formula.default = ~ open + high + low + close + volume
	)

	## NOTE: x is a <data.frame>
	##       but SPY are a matrix
	testthat::expect_equal(
		as.matrix(x),
		SPY
	)
})
