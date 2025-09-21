## usethis namespace: start
#' @useDynLib talib, .registration = TRUE
## usethis namespace: end
NULL

#' @title Generic function documentation
#' @name generic_documentation
#'
#' @description
#' A generic documentation block for documenting parameters that
#' are common across all functions. Avoids documenting parameters
#' that doesn't exist downstream.
#'
#' @param x An OHLC-V series that is coercible to [data.frame]. The function assumes that all columns are named in lowercase and order invariant.
#' @param cols An optional [formula] passed into [model.frame]. If passed into indicators based on univariate series, the function calculates indicators for each element in 'cols'. For indicators based on multivariate series, it will alter the calculation itself. See `vignette("talib")` for more details.
#' @param n An [integer] of [length] 1.
#' @param ... Additional parameters passed into [model.frame]
#'
#' @returns NULL
#' @keywords internal
#' @usage NULL
NULL
