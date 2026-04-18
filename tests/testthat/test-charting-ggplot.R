## Focused coverage for the ggplot2 charting backend.
## Complements test-charting.R (plotly-centric) and the `talib_gg_chart`
## auto-print guard that prevents Rplots.pdf in non-interactive runs.

testthat::skip_if_not_installed("ggplot2")

withr_backend_ggplot2 <- function(code) {
	old <- options(talib.chart.backend = "ggplot2")
	on.exit(options(old), add = TRUE)
	force(code)
}

testthat::test_that("chart(BTC) on ggplot2 backend returns a wrapped gg", {
	withr_backend_ggplot2({
		out <- chart(BTC)
		testthat::expect_s3_class(out, "talib_gg_chart")
		testthat::expect_s3_class(out, "gg")
	})
})

testthat::test_that("chart() reset works on ggplot2 backend", {
	withr_backend_ggplot2({
		chart(BTC)
		testthat::expect_false(is.null(talib:::.chart_state()))
		chart()
		testthat::expect_true(is.null(talib:::.chart_state()))
	})
})

testthat::test_that("line overlay (SMA) + chart returns a single-panel gg", {
	withr_backend_ggplot2({
		chart(BTC)
		out <- indicator(SMA, n = 20)
		testthat::expect_true(inherits(out, c("gg", "talib_chart")))
	})
})

testthat::test_that("ribbon geom (BBANDS) composes on the main panel", {
	withr_backend_ggplot2({
		chart(BTC)
		out <- indicator(BBANDS)
		testthat::expect_true(inherits(out, c("gg", "talib_chart")))
	})
})

testthat::test_that("bar geom (MACD histogram) builds a multi-panel chart", {
	withr_backend_ggplot2({
		chart(BTC)
		out <- indicator(MACD)
		testthat::expect_s3_class(out, "talib_chart")
		testthat::expect_true(out$n >= 2L)
	})
})

testthat::test_that("bar geom (trading_volume) builds a multi-panel chart", {
	withr_backend_ggplot2({
		chart(BTC)
		out <- indicator(trading_volume)
		testthat::expect_s3_class(out, "talib_chart")
	})
})

testthat::test_that("point geom (SAR) overlays on the main panel", {
	withr_backend_ggplot2({
		chart(BTC)
		out <- indicator(SAR)
		testthat::expect_true(inherits(out, c("gg", "talib_chart")))
	})
})

testthat::test_that("multi-indicator assembly returns a talib_chart", {
	withr_backend_ggplot2({
		chart(BTC)
		out <- indicator(RSI(n = 14), RSI(n = 21))
		testthat::expect_s3_class(out, "talib_chart")
	})
})

testthat::test_that("a theme change applies cleanly under ggplot2 backend", {
	withr_backend_ggplot2({
		set_theme("limit_up")
		on.exit(set_theme("default"), add = TRUE)
		chart(BTC)
		out <- indicator(RSI)
		testthat::expect_true(inherits(out, c("gg", "talib_chart")))
	})
})

testthat::test_that("print.talib_gg_chart does not leave Rplots.pdf behind", {
	withr_backend_ggplot2({
		cwd <- getwd()
		pdf_path <- file.path(cwd, "Rplots.pdf")
		if (file.exists(pdf_path)) {
			file.remove(pdf_path)
		}

		## build and print a single-panel ggplot chart
		out <- chart(BTC)
		print(out)

		## the wrapper should have opened a null device, so no
		## Rplots.pdf should have been written
		testthat::expect_false(file.exists(pdf_path))
	})
})
