## script: MACDFIXED
## author: Serkan Korkmaz
testthat::test_that(desc = "Moving Average Convergence Divergence (Fixed)", code = {
	## 1) calculate values
	##    with and without alias
	output <- moving_average_convergence_divergence(
		SPY
	)
	alias <- MACDFIX(SPY)

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
			indicator(moving_average_convergence_divergence(
				fast = EMA(n = 12),
				slow = EMA(n = 26),
				signal = EMA(n = 9),
			))
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
		inherits(
			moving_average_convergence_divergence(SPY),
			class(SPY)
		)
	)

	## 3.2) data.frame
	testthat::expect_true(
		inherits(
			moving_average_convergence_divergence(BTC),
			class(BTC)
		)
	)

	## 4) test that default
	##    values equals
	testthat::expect_equal(
		object = moving_average_convergence_divergence(
			BTC
		),
		expected = moving_average_convergence_divergence(
			BTC,
			cols = ~close
		)
	)
})
