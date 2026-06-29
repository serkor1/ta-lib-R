#' @export
#' @family Utility
#'
#' @title Calculate lookback period
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
#'  x = talib::BTC
#' )
#'
#' @param FUN A [call] or [function].
#' @param ... Additional parameters passed into the indicator function. See examples for more details.
#'
#' @concept finance
#' @concept technical analysis
#' @concept trading
#' @concept algorithmic trading
#'
#'
#' @author Serkan Korkmaz
#'
#' @returns
#' The minimum lookback required to calculate the indicator.
#' If the indicator specification and input data are invalid the function returns [NA], otherwise it returns an [integer] of [length] 1.
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

	## important distinction with substitute:
	## 	pkg::foo() -> call
	## 	foo -> function
	if (is.call(FUN)) {
		FUN <- FUN[[length(FUN)]]
	}

	## validate input arguments
	## to avoid downstream shenanigans
	## 	talib::BBANDS with non-existing arguments
	##  like 'n' will break stuff
	passed_arguments <- names(c(
		as.list(
			environment()
		),
		list(...)
	))[-c(1:2)]

	actual_arguments <- names(
		formals(
			as.character(FUN)
		)
	)

	## stop the function early instead
	## of silently modifying the underlying
	## call - this seems to be the optimal choice
	## as the lookback function is a development function
	## more than a "regular user"-function, so it is
	## expected that the developer knows what its doing.
	if (!all(passed_arguments %in% actual_arguments)) {
		stop(
			sprintf(
				"The `lookback()` is strictly typed.
				\rArguments passed into ... has to match that of `%s()` with no additional phantom variables.",
				as.character(FUN)
			)
		)
	}

	## all exported indicators has
	## a _lookback post-fix which handles
	## the lookback calculation
	FUN <- paste0(
		as.character(FUN),
		"_lookback"
	)

	if (!exists(FUN, envir = ns, mode = "function", inherits = FALSE)) {
		## strip FUN to get
		## the basename of the passed
		## function
		FUN <- gsub(
			pattern = "_lookback",
			replacement = "",
			x = FUN
		)

		## stop the function with
		## a hard error.
		## TODO: Consider the case for
		## custom indicators, wrapper functions
		## or exported functions that does not have
		## a lookback-calculation.
		stop(
			"No indicator named `",
			FUN,
			"` was found.",
			call. = FALSE
		)
	}

	FUN <- get(
		FUN,
		envir = ns,
		mode = "function",
		inherits = FALSE
	)

	## upstream returns -1
	## for invalid input data
	## relative to the indicator;
	## 	SMA, for example, requires at
	##  minimum two data points to calculate
	##  given n = 2 - and three, if n = 3.
	##
	## if the indicator and input are not
	## satisfying this constraint upstream
	## returns -1, ie. not applicable.
	minimum_lookback <- do.call(
		FUN,
		args = list(...)
	)

	if (minimum_lookback == -1) {
		return(NA)
	}

	## volume, for example, returns
	## a lookback of 0 if calculated without
	## moving averages - wrap the lookback
	## in max() as a safety precaution
	max(
		minimum_lookback,
		1,
		na.rm = TRUE
	)
}
