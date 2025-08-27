## script: Doji
## author: Serkan Korkmaz
testthat::test_that(desc = "Doji", code = {
  ## 1) calculate values
  ##    with and without alias
  ##    without normalization
  options(talib.normalize = FALSE)
  output <- doji(SPY)
  alias <- CDLDOJI(SPY)

  ## 1.1) check if the values
  ##      are equal
  testthat::expect_equal(
    object = output,
    expected = alias
  )

  ## 1.2) check that the range
  ##      is in [0, 100]
  testthat::expect_true(
    object = any(unique(output, na.rm = TRUE) %in% c(100))
  )

  ## 1.3) recalculate with
  ##      normalization and check
  ##      range is in [0, 1]
  options(talib.normalize = TRUE)
  output <- CDLDOJI(SPY)

  ## 1.4) check that the range
  ##      is in [-1, 1]
  testthat::expect_true(
    object = any(unique(output, na.rm = TRUE) %in% c(1))
  )
})
