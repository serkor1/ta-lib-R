## tests for per-frame chart state isolation
## verifies that two concurrent-style chart() pipelines do not collide

testthat::test_that("function-body state is isolated from other function bodies", {
	fa <- function() {
		chart(BTC)
		talib:::.chart_state()$x[1L, "close"]
	}
	fb <- function() {
		chart(SPY)
		talib:::.chart_state()$x[1L, "close"]
	}

	btc_close <- fa()
	spy_close <- fb()
	btc_close2 <- fa()

	## fa()'s second call should see BTC again, not SPY -
	## each invocation has its own frame, state doesn't leak
	testthat::expect_equal(btc_close, btc_close2)
	testthat::expect_false(identical(btc_close, spy_close))
})

testthat::test_that("local() blocks don't share state with siblings", {
	## wipe any globalenv-level leftover from previous tests
	chart()

	local({
		chart(BTC)
		testthat::expect_false(is.null(talib:::.chart_state()))
	})

	local({
		## fresh local() env - should not see the previous block's state
		testthat::expect_true(is.null(talib:::.chart_state()))
	})
})

testthat::test_that("chart() with no args clears state in caller's frame", {
	f <- function() {
		chart(BTC)
		testthat::expect_false(is.null(talib:::.chart_state()))
		chart()
		testthat::expect_true(is.null(talib:::.chart_state()))
	}
	f()
})

testthat::test_that("standalone indicator() gets transient state that doesn't leak", {
	chart()

	## call standalone - uses transient state inside indicator()
	out <- indicator(RSI, data = BTC)

	## state must not persist after indicator() returns
	testthat::expect_true(is.null(talib:::.chart_state()))

	## and the returned object is a chart
	testthat::expect_true(inherits(out, c("plotly", "gg")))
})
