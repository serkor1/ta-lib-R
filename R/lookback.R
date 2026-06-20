#' Calculate lookback period
#'
#' @description
#' The function calculates the lookback period for a given
#' indicator.
#' Its primarily meant as a helper function for downstream packages
#' that wants to use a customized control-flow.
#'
#' @examples
#' ## calculate the lookback
#' ## for the bollinger bands
#' talib::lookback(
#' 	talib::bollinger_bands,
#'  n = 20,
#'  x = talib::BTC
#' )
#'
#' @param FUN A [call] or [function].
#' @param ... Additional parameters passed into the indicator function. See examples for more details.
#'
#' @returns
#' An [integer] of [length] 1.
#'
#' @export
lookback <- function(
	FUN,
	...
) {
	## store {talib} as a namespace
	## so the function can be found
	## (*_lookback is not exported)
	ns <- getNamespace(
		"talib"
	)

	## extract the function call
	## as-is
	FUN <- substitute(
		FUN
	)

	if (is.call(FUN)) {
		FUN <- FUN[[length(FUN)]]
	}

	fun_name <- paste0(as.character(FUN), "_lookback")

	if (!exists(fun_name, envir = ns, mode = "function", inherits = FALSE)) {
		stop(
			"No internal function named `",
			fun_name,
			"` was found.",
			call. = FALSE
		)
	}

	FUN <- get(fun_name, envir = ns, mode = "function", inherits = FALSE)

	do.call(FUN, args = list(...))
}
