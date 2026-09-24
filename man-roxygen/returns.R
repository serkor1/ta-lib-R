#' @returns
#'
#' An object of same [class] and [length] of `x`:
#'
#' `r BTC <- talib::BTC; generate_returns_section(<%= tolower(.fun) %>(BTC<%= if (.fun == "variable_moving_average_period") ", periods = runif(nrow(BTC), 10, 20)" else "" %>))`
