## script - test charting infrastructure
## author - Serkan Korkmaz

## ---- chart() ----

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
			chart(BTC)
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

## test chart reset
testthat::test_that(desc = "chart() reset clears environment", code = {
	## chart then reset
	chart(BTC)
	chart()

	## indicator should require data
	## since chart state was cleared
	testthat::expect_error(
		indicator(RSI)
	)
})

## ---- set_theme() ----

## test charting with themes
testthat::test_that(desc = "Charting with Themes", code = {
	## 1) test chart with set_theme()
	testthat::expect_no_error(
		{
			set_theme$hawks_and_doves
			chart(SPY)
		}
	)

	testthat::expect_no_error(
		{
			set_theme$payout
			chart(SPY)
		}
	)

	testthat::expect_no_error(
		{
			set_theme$tp_slapped
			chart(SPY)
		}
	)

	testthat::expect_no_error(
		{
			set_theme$trust_the_process
			chart(SPY)
		}
	)
})

## test set_theme() API
testthat::test_that(desc = "set_theme API", code = {
	## list available themes
	themes <- set_theme()
	testthat::expect_true(is.character(themes))
	testthat::expect_true(length(themes) > 0)

	## apply by name
	testthat::expect_no_error(
		set_theme("payout")
	)

	## apply with overrides
	testthat::expect_no_error(
		set_theme("payout", background_color = "#000000")
	)

	## override only
	testthat::expect_no_error(
		set_theme(background_color = "#111111")
	)
})

## ---- indicator() multi-indicator mode ----

## test multi-indicator on same panel - plotly
testthat::test_that(desc = "Multi-indicator mode plotly", code = {
	output <- testthat::expect_no_error(
		{
			chart(BTC)
			indicator(RSI(n = 10), RSI(n = 14))
		}
	)

	testthat::expect_true(
		inherits(output, "plotly")
	)
})

## test multi-indicator with different types - plotly
testthat::test_that(desc = "Multi-indicator mixed types plotly", code = {
	output <- testthat::expect_no_error(
		{
			chart(BTC)
			indicator(RSI(n = 14), CMO())
		}
	)

	testthat::expect_true(
		inherits(output, "plotly")
	)
})

## test multi-indicator requires chart()
testthat::test_that(desc = "Multi-indicator requires chart()", code = {
	chart()
	testthat::expect_error(
		indicator(RSI(n = 10), RSI(n = 14))
	)
})

## ---- indicator() standalone mode ----

## test standalone indicator - plotly
testthat::test_that(desc = "Standalone indicator plotly", code = {
	chart()
	output <- testthat::expect_no_error(
		indicator(RSI, data = BTC, n = 14)
	)

	testthat::expect_true(
		inherits(output, "plotly")
	)
})

## test standalone indicator - ggplot2
testthat::test_that(desc = "Standalone indicator ggplot2", code = {
	testthat::skip_if_not_installed("ggplot2")

	chart()
	options(talib.chart.backend = "ggplot2")
	on.exit(options(talib.chart.backend = "plotly"))

	output <- testthat::expect_no_error(
		indicator(RSI, data = BTC, n = 14)
	)

	testthat::expect_true(
		inherits(output, "gg")
	)
})

## ---- ggplot2 backend ----

## test ggplot2 backend charting
testthat::test_that(desc = "ggplot2 backend charting", code = {
	testthat::skip_if_not_installed("ggplot2")

	options(talib.chart.backend = "ggplot2")
	on.exit(options(talib.chart.backend = "plotly"))

	## 1) basic chart
	## 1.1) matrix
	output <- testthat::expect_no_error(
		chart(SPY)
	)
	testthat::expect_true(inherits(output, "gg"))

	## 1.2) data.frame
	output <- testthat::expect_no_error(
		chart(BTC)
	)
	testthat::expect_true(inherits(output, "gg"))

	## 2) chart + indicator
	output <- testthat::expect_no_error(
		{
			chart(BTC)
			indicator(SMA)
		}
	)
	testthat::expect_true(
		inherits(output, "gg") || inherits(output, "talib_chart")
	)
})

## test ggplot2 backend with themes
testthat::test_that(desc = "ggplot2 backend with themes", code = {
	testthat::skip_if_not_installed("ggplot2")

	options(talib.chart.backend = "ggplot2")
	on.exit(options(talib.chart.backend = "plotly"))

	for (theme in set_theme()) {
		testthat::expect_no_error(
			{
				set_theme(theme)
				chart(SPY)
			}
		)
	}
})

## test ggplot2 OHLC bar type
testthat::test_that(desc = "ggplot2 backend OHLC type", code = {
	testthat::skip_if_not_installed("ggplot2")

	options(talib.chart.backend = "ggplot2")
	on.exit(options(talib.chart.backend = "plotly"))

	output <- testthat::expect_no_error(
		chart(SPY, type = "ohlc")
	)
	testthat::expect_true(inherits(output, "gg"))
})

## ---- ggplot2 multi-indicator mode ----

## test multi-indicator on same panel - ggplot2
testthat::test_that(desc = "Multi-indicator mode ggplot2", code = {
	testthat::skip_if_not_installed("ggplot2")

	options(talib.chart.backend = "ggplot2")
	on.exit(options(talib.chart.backend = "plotly"))

	output <- testthat::expect_no_error(
		{
			chart(BTC)
			indicator(RSI(n = 10), RSI(n = 14))
		}
	)

	testthat::expect_true(
		inherits(output, "gg") || inherits(output, "talib_chart")
	)
})

## test multi-indicator with different types - ggplot2
testthat::test_that(desc = "Multi-indicator mixed types ggplot2", code = {
	testthat::skip_if_not_installed("ggplot2")

	options(talib.chart.backend = "ggplot2")
	on.exit(options(talib.chart.backend = "plotly"))

	output <- testthat::expect_no_error(
		{
			chart(BTC)
			indicator(RSI(n = 14), CMO())
		}
	)

	testthat::expect_true(
		inherits(output, "gg") || inherits(output, "talib_chart")
	)
})

## ---- mixed indicator types (pattern + overlay + subchart) ----

## test that candlestick patterns can be mixed with
## overlay and subchart indicators on the plotly backend
testthat::test_that(desc = "Mixed patterns and indicators plotly", code = {
	output <- testthat::expect_no_error(
		{
			set_theme$hawks_and_doves
			chart(BTC)
			indicator(harami)
			indicator(bollinger_bands)
			indicator(MACD)
		}
	)

	testthat::expect_true(
		inherits(output, "plotly")
	)
})

## test that candlestick patterns can be mixed with
## overlay and subchart indicators on the ggplot2 backend
testthat::test_that(desc = "Mixed patterns and indicators ggplot2", code = {
	testthat::skip_if_not_installed("ggplot2")

	options(talib.chart.backend = "ggplot2")
	on.exit(options(talib.chart.backend = "plotly"))

	output <- testthat::expect_no_error(
		{
			set_theme$hawks_and_doves
			chart(BTC)
			indicator(harami)
			indicator(bollinger_bands)
			indicator(MACD)
		}
	)

	testthat::expect_true(
		inherits(output, "gg") || inherits(output, "talib_chart")
	)
})

## ---- reset theme to default ----

## clean up after tests
testthat::test_that(desc = "Reset theme", code = {
	set_theme("default")
	testthat::expect_true(TRUE)
})
