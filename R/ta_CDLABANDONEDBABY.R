#' @export
#' @family Pattern Recognition
#'
#' @title Abandoned Baby
#'
#' @templateVar .title Abandoned Baby
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun abandoned_baby
#'
#' @template description
#'
#' @returns
#' \describe{
#'  \item{abandoned_baby}{1 for bullish, -1 for bearish and 0 for no pattern}
#' }
abandoned_baby <- function(
	x,
	cols,
	eps = 0,
	...
) {
	UseMethod(
		"abandoned_baby"
	)
}

#' @usage NULL
#' @aliases abandoned_baby
#' @export
CDLABANDONEDBABY <- abandoned_baby

#' @usage NULL
#' @aliases abandoned_baby
#' @export
abandoned_baby.default <- function(
	x,
	cols,
	eps = 0,
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
			"impl_ta_CDLABANDONEDBABY",
			OHLC[[1]],
			OHLC[[2]],
			OHLC[[3]],
			OHLC[[4]],
			as.double(eps),
			as.logical(
				getOption("talib.normalize", TRUE)
			)
		)
	)

	## set column names
	colnames(x) <- "abandoned_baby"

	## return value
	return(x)
}

#' @usage NULL
#' @aliases abandoned_baby
#' @export
abandoned_baby.data.frame <- function(
	x,
	cols,
	eps = 0,
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases abandoned_baby
#' @export
abandoned_baby.matrix <- function(
	x,
	cols,
	eps = 0,
	...
) {
	as.matrix(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases abandoned_baby
#' @export
abandoned_baby.plotly <- function(
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
	.indicator <- abandoned_baby.default(
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
		pattern_name = "Abandoned Baby"
	)

	.plotting_environment$main
}
