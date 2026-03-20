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
