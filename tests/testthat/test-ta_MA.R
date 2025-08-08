## script: MA
## author: Serkan Korkmaz
testthat::test_that(desc = "Simple Moving Average", code = {

    ## 1) calculate values
    ##    with and without alias
    output <- simple_moving_average(SPY[,1])
    alias  <- SMA(SPY[,1])

    ## 1.1) check if the values
    ##      are equal
    testthat::expect_equal(
        object    = output,
        expected  = alias
    )

    ## 1.2) check if the values
    ##      have same length
    testthat::expect_equal(
        object   = nrow(SPY),
        expected = length(output) 
    )

})

testthat::test_that(desc = "Exponential Moving Average", code = {

    ## 1) calculate values
    ##    with and without alias
    output <- exponential_moving_average(SPY[,1])
    alias  <- EMA(SPY[,1])

    ## 1.1) check if the values
    ##      are equal
    testthat::expect_equal(
        object    = output,
        expected  = alias
    )

    ## 1.2) check if the values
    ##      have same length
    testthat::expect_equal(
        object   = nrow(SPY),
        expected = length(output) 
    )

})

testthat::test_that(desc = "Weighted Moving Average", code = {

    ## 1) calculate values
    ##    with and without alias
    output <- weighted_moving_average(SPY[,1])
    alias  <- WMA(SPY[,1])

    ## 1.1) check if the values
    ##      are equal
    testthat::expect_equal(
        object    = output,
        expected  = alias
    )

    ## 1.2) check if the values
    ##      have same length
    testthat::expect_equal(
        object   = nrow(SPY),
        expected = length(output) 
    )

})

testthat::test_that(desc = "Double Exponential Moving Average", code = {

    ## 1) calculate values
    ##    with and without alias
    output <- double_exponential_moving_average(SPY[,1])
    alias  <- DEMA(SPY[,1])

    ## 1.1) check if the values
    ##      are equal
    testthat::expect_equal(
        object    = output,
        expected  = alias
    )

    ## 1.2) check if the values
    ##      have same length
    testthat::expect_equal(
        object   = nrow(SPY),
        expected = length(output) 
    )

})

testthat::test_that(desc = "Triple Exponential Moving Average", code = {

    ## 1) calculate values
    ##    with and without alias
    output <- triple_exponential_moving_average(SPY[,1])
    alias  <- TEMA(SPY[,1])

    ## 1.1) check if the values
    ##      are equal
    testthat::expect_equal(
        object    = output,
        expected  = alias
    )

    ## 1.2) check if the values
    ##      have same length
    testthat::expect_equal(
        object   = nrow(SPY),
        expected = length(output) 
    )

})

testthat::test_that(desc = "Triangular Moving Average", code = {

    ## 1) calculate values
    ##    with and without alias
    output <- triangular_moving_average(SPY[,1])
    alias  <- TRIMA(SPY[,1])

    ## 1.1) check if the values
    ##      are equal
    testthat::expect_equal(
        object    = output,
        expected  = alias
    )

    ## 1.2) check if the values
    ##      have same length
    testthat::expect_equal(
        object   = nrow(SPY),
        expected = length(output) 
    )

})

testthat::test_that(desc = "Kaufman’s Adaptive Moving Average", code = {

    ## 1) calculate values
    ##    with and without alias
    output <- kaufman_adaptive_moving_average(SPY[,1])
    alias  <- KAMA(SPY[,1])

    ## 1.1) check if the values
    ##      are equal
    testthat::expect_equal(
        object    = output,
        expected  = alias
    )

    ## 1.2) check if the values
    ##      have same length
    testthat::expect_equal(
        object   = nrow(SPY),
        expected = length(output) 
    )

})

testthat::test_that(desc = "Mesa Adaptive Moving Average", code = {

    ## 1) calculate values
    ##    with and without alias
    output <- mesa_adaptive_moving_average(SPY[,1])
    alias  <- MAMA(SPY[,1])

    ## 1.1) check if the values
    ##      are equal
    testthat::expect_equal(
        object    = output,
        expected  = alias
    )

    ## 1.2) check if the values
    ##      have same length
    testthat::expect_equal(
        object   = nrow(SPY),
        expected = length(output) 
    )

})

testthat::test_that(desc = "T3 Moving Average", code = {

    ## 1) calculate values
    ##    with and without alias
    output <- t3_moving_average(SPY[,1])
    alias  <- T3(SPY[,1])

    ## 1.1) check if the values
    ##      are equal
    testthat::expect_equal(
        object    = output,
        expected  = alias
    )

    ## 1.2) check if the values
    ##      have same length
    testthat::expect_equal(
        object   = nrow(SPY),
        expected = length(output) 
    )

})