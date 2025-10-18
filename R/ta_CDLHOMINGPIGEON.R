#' @export
#' @family Pattern Recognition
#'
#' @title Homing Pigeon
#'
#' @templateVar .title Homing Pigeon
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun homing_pigeon
#'
#' @template description
#'
#' @returns
#' \describe{
#'  \item{homing_pigeon}{1 for bullish, -1 for bearish and 0 for no pattern}
#' }
homing_pigeon <- function(
	x,
	cols,
	...
) {
	UseMethod(
		"homing_pigeon"
	)
}

#' @export
#'
#' @usage NULL
#'
#' @rdname homing_pigeon
#' @aliases homing_pigeon
CDLHOMINGPIGEON <- homing_pigeon

#' @usage NULL
#' @aliases homing_pigeon
#' @export
homing_pigeon.default <- function(
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
			"impl_ta_CDLHOMINGPIGEON",
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
	colnames(x) <- "homing_pigeon"

	## return value
	return(x)
}

#' @usage NULL
#' @aliases homing_pigeon
#' @export
homing_pigeon.data.frame <- function(
	x,
	cols,
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases homing_pigeon
#' @export
homing_pigeon.matrix <- function(
	x,
	cols,
	...
) {
	as.matrix(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases homing_pigeon
#' @export
homing_pigeon.plotly <- function(
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
	.indicator <- homing_pigeon.default(
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
		pattern_name = "homing_pigeon"
	)

	.plotting_environment$main
}
