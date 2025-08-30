## script: AD
## author: Serkan Korkmaz
testthat::test_that(desc = "Aroon Oscillator", code = {
	## 1) calculate values
	##    with and without alias
	output <- aroon_oscillator(SPY)
	alias <- AROONOSC(SPY)

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
			indicator(aroon_oscillator())
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
		inherits(aroon_oscillator(SPY), class(SPY))
	)

	## 3.2) data.frame
	testthat::expect_true(
		inherits(aroon_oscillator(BTC), class(BTC))
	)

	## 4) test that default
	##    values equals
	testthat::expect_equal(
		object = aroon_oscillator(
			BTC
		),
		expected = aroon_oscillator(
			BTC,
			cols = ~ high + low
		)
	)
})
