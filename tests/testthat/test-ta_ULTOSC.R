## script: AD
## author: Serkan Korkmaz
testthat::test_that(desc = "Ultimate Oscillator", code = {
	## 1) calculate values
	##    with and without alias
	output <- ultimate_oscillator(SPY)
	alias <- ULTOSC(SPY)

	## 1.1) check if the values
	##      are equal
	testthat::expect_equal(
		object = output,
		expected = alias
	)

	## 2) test that charting
	##    works
	output <- testthat::expect_no_error(
		{
			chart(BTC)
			indicator(ultimate_oscillator())
		}
	)

	## 2.1) test that it outputs
	##      a plotly object
	testthat::expect_true(
		inherits(output, "plotly")
	)

	## 3) test class-in and class-out
	##    equality

	## 3.1) matrix
	testthat::expect_true(
		inherits(ultimate_oscillator(SPY), class(SPY))
	)

	## 3.2) data.frame
	testthat::expect_true(
		inherits(ultimate_oscillator(BTC), class(BTC))
	)

	## 4) test that default
	##    values equals
	testthat::expect_equal(
		object = ultimate_oscillator(
			BTC
		),
		expected = ultimate_oscillator(
			BTC,
			cols = ~ high + low + close
		)
	)
})
