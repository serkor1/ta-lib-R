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

## tests for the <xts> column-resolution path:
## columns resolve per formula variable, in formula
## order - never by physical layout
testthat::test_that(desc = "<xts> columns resolve in formula order", code = {
	testthat::skip_if_not_installed("xts")

	idx <- as.Date("2024-01-01") + 0:9

	## physical order must not dictate
	## the selection order
	x <- xts::xts(
		cbind(Low = 0:9, Close = 1:10, High = 2:11),
		order.by = idx
	)

	testthat::expect_equal(
		colnames(talib:::series(x = x, formula.default = ~ high + low + close)),
		c("High", "Low", "Close")
	)

	## quantmod-style names resolve
	## by suffix
	colnames(x) <- paste0("GOOGL.", c("Low", "Close", "High"))

	testthat::expect_equal(
		colnames(talib:::series(x = x, formula.default = ~ high + low + close)),
		paste0("GOOGL.", c("High", "Low", "Close"))
	)

	## lowercase names resolve exactly
	colnames(x) <- c("low", "close", "high")

	testthat::expect_equal(
		colnames(talib:::series(x = x, formula.default = ~ high + low + close)),
		c("high", "low", "close")
	)

	## an explicit formula is selected
	## exactly as passed
	testthat::expect_equal(
		colnames(talib:::series(
			x = x,
			formula = ~ low + high + close,
			formula.default = ~ high + low + close
		)),
		c("low", "high", "close")
	)
})

testthat::test_that(desc = "<xts> column-resolution failures", code = {
	testthat::skip_if_not_installed("xts")

	idx <- as.Date("2024-01-01") + 0:9
	x <- xts::xts(
		cbind(high = 2:11, low = 0:9, close = 1:10),
		order.by = idx
	)

	## no matching columns
	testthat::expect_error(
		talib:::series(
			x = xts::xts(cbind(a = 1:10, b = 1:10), order.by = idx),
			formula.default = ~close
		)
	)

	## ambiguous matches
	ambiguous <- xts::xts(cbind(1:10, 1:10), order.by = idx)
	colnames(ambiguous) <- c("Close", "close")

	testthat::expect_error(
		talib:::series(
			x = ambiguous,
			formula.default = ~close
		)
	)

	## an explicit formula shorter than
	## the default
	testthat::expect_error(
		talib:::series(
			x = x,
			formula = ~close,
			formula.default = ~ high + low + close
		)
	)

	## 'subset' and the remaining
	## model.frame-arguments are unused
	testthat::expect_warning(
		talib:::series(
			x = x,
			formula.default = ~ high + low + close,
			subset = 1:5
		)
	)
})

## the <xts> methods must work without {xts} attached:
## assert_xts() loads the namespace on demand
testthat::test_that(desc = "<xts> input works without {xts} attached", code = {
	testthat::skip_if_not_installed("xts")
	testthat::skip_on_cran()

	script <- paste0(
		".libPaths(",
		paste(deparse(.libPaths()), collapse = ""),
		"); library(talib); ",
		"x <- relative_strength_index(GOOGL); ",
		"stopifnot(inherits(x, 'xts'), !all(is.na(x))); ",
		"cat('vanilla-ok')"
	)

	output <- suppressWarnings(system2(
		file.path(R.home("bin"), "Rscript"),
		args = c("--vanilla", "-e", shQuote(script)),
		stdout = TRUE,
		stderr = TRUE
	))

	testthat::expect_true(any(grepl("vanilla-ok", output)))
})
