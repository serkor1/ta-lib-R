## script: MACD
## author: Serkan Korkmaz
testthat::test_that(desc = "MACD", code = {
  ## 1) calculate values
  ##    with and without alias
  output <- moving_average_convergence_divergence(SPY[, 1])
  alias <- MACD(SPY[, 1])

  ## 1.1) check if the values
  ##      are equal is by default
  testthat::expect_equal(
    object = output,
    expected = alias
  )
})

testthat::test_that(desc = "MACDFIX", code = {
  ## 1) calculate values
  ##    with and without alias
  output <- moving_average_convergence_divergence(SPY[, 1])
  alias <- MACDFIX(SPY[, 1])

  ## 1.1) check if the values
  ##      are equal is by default
  testthat::expect_equal(
    object = output,
    expected = alias
  )
})

testthat::test_that(desc = "MACDEXT", code = {
  ## 1) calculate values
  ##    with and without alias
  output <- moving_average_convergence_divergence(
    SPY[, 1],
    EMA(n = 12),
    EMA(n = 26),
    EMA(n = 9)
  )
  alias <- MACDEXT(SPY[, 1])

  ## 1.1) check if the values
  ##      are equal is by default
  testthat::expect_equal(
    object = output,
    expected = alias
  )
})
