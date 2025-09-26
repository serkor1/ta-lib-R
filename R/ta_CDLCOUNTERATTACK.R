#' @export
#' @family Pattern Recognition
#'
#' @title Counter Attack
#'
#' @templateVar .title Counter Attack
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun counter_attack
#'
#' @template description
#'
#' @returns
#' \describe{
#'  \item{counter_attack}{1 for bullish, -1 for bearish and 0 for no pattern}
#' }
counter_attack <- function(
	x,
	cols,
	...
) {
	UseMethod(
		"counter_attack"
	)
}

#' @export
#'
#' @usage NULL
#'
#' @rdname counter_attack
#' @aliases counter_attack
CDLCOUNTERATTACK <- counter_attack

#' @usage NULL
#' @aliases counter_attack
#' @export
counter_attack.default <- function(
	x,
	cols,
	...
) {
	## validate input
	## asssuming everyting
	## is numerical values
	if (!missing(cols)) {
		## check if formula
		assert(
			is.formula(cols),
			paste0(
				"'cols' has to be <",
				class(~s),
				">. ",
				"Got <",
				class(cols),
				">."
			)
		)

		## check if formula has the expected
		## length
		assert(
			length(all.vars(cols)) == 4,
			paste0(
				"'cols' has to be length 4. ",
				"Got length ",
				length(all.vars(cols))
			)
		)
	}

	## construct OHLC-series
	## from 'x'
	OHLC <- series(
		x = cols,
		default = ~ open + high + low + close,
		data = x,
		...
	)

	## construct data.frame
	## from source
	x <- as.data.frame(
		.Call(
			"impl_ta_CDLCOUNTERATTACK",
			OHLC[[1]],
			OHLC[[2]],
			OHLC[[3]],
			OHLC[[4]],
			as.logical(
				getOption("talib.normalize", TRUE)
			)
		)
	)

	## set column names
	colnames(x) <- "counter_attack"

	## return value
	return(x)
}

#' @usage NULL
#' @aliases counter_attack
#' @export
counter_attack.data.frame <- function(
	x,
	cols,
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases counter_attack
#' @export
counter_attack.matrix <- function(
	x,
	cols,
	...
) {
	as.matrix(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases counter_attack
#' @export
counter_attack.plotly <- function(
	x,
	cols,
	...
) {
	## prepare OHLC series
	OHLC <- series(
		x = x,
		formula = cols,
		default = ~ open + high + low + close,
		...
	)

	## calculate pattern
	## indicators
	.indicator <- counter_attack.default(
		x = OHLC,
		cols = ~ open + high + low + close
	)

	.indicator$idx <- 1:nrow(.indicator)

	## chart patterns
	.plotting_environment$main <- pattern(
		p = .plotting_environment$main,
		x = .indicator,
		high = OHLC[[2]],
		low = OHLC[[3]],
		pattern_name = "Counter Attack"
	)

	.plotting_environment$main
}
