#' @export
#' @family Pattern Recognition
#'
#' @title In Neck
#'
#' @templateVar .title In Neck
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun in_neck
#'
#' @template description
#'
#' @returns
#' \describe{
#'  \item{in_neck}{1 for bullish, -1 for bearish and 0 for no pattern}
#' }
in_neck <- function(
	x,
	cols,
	...
) {
	UseMethod(
		"in_neck"
	)
}

#' @export
#'
#' @usage NULL
#'
#' @rdname in_neck
#' @aliases in_neck
CDLINNECK <- in_neck

#' @usage NULL
#' @aliases in_neck
#' @export
in_neck.default <- function(
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
			"impl_ta_CDLINNECK",
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
	colnames(x) <- "in_neck"

	## return value
	return(x)
}

#' @usage NULL
#' @aliases in_neck
#' @export
in_neck.data.frame <- function(
	x,
	cols,
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases in_neck
#' @export
in_neck.matrix <- function(
	x,
	cols,
	...
) {
	as.matrix(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases in_neck
#' @export
in_neck.plotly <- function(
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
	.indicator <- in_neck.default(
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
		pattern_name = "in_neck"
	)

	.plotting_environment$main
}
