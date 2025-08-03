## script: Average Price
## author: Serkan Korkmaz
## objective:
##
##
testthat::test_that(desc = "average_price()", code = {
  
  ## 1) generate matrix
  ohlc <- data.frame(
    Open  = c(1,2,3), 
    High  = c(2,3,4), 
    Low   = c(0.5,1.5,2.5), 
    Close = c(1.5,2.5,3.5)
  )

  avg <- average_price(ohlc)

  ## 2) check values
  testthat::expect_equal(
    object = avg,
    expected = c(1.25, 2.25, 3.25)
  )
  
})