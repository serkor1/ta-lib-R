#' @export
#' @family Pattern Recognition
#'
#' @title Identical Three Crows
#'
#' @templateVar .title Identical Three Crows
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun three_identical_crows
#'
#' @template description
#'
#' @returns
#' \describe{
#'  \item{three_identical_crows}{1 for bullish, -1 for bearish and 0 for no pattern}
#' }
three_identical_crows <- function(
	x,
	cols,
	...
) {
	UseMethod(
		"three_identical_crows"
	)
}

#' @export
#'
#' @usage NULL
#'
#' @rdname three_identical_crows
#' @aliases three_identical_crows
CDLIDENTICAL3CROWS <- three_identical_crows

#' @usage NULL
#' @aliases three_identical_crows
#' @export
three_identical_crows.default <- function(
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
			"impl_ta_CDLIDENTICAL3CROWS",
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
	colnames(x) <- "three_identical_crows"

	## return value
	return(x)
}

#' @usage NULL
#' @aliases three_identical_crows
#' @export
three_identical_crows.data.frame <- function(
	x,
	cols,
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases three_identical_crows
#' @export
three_identical_crows.matrix <- function(
	x,
	cols,
	...
) {
	as.matrix(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases three_identical_crows
#' @export
three_identical_crows.plotly <- function(
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
	.indicator <- three_identical_crows.default(
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
		pattern_name = "three_identical_crows"
	)

	.plotting_environment$main
}
