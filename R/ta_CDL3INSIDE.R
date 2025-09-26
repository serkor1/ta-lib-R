#' @export
#' @family Pattern Recognition
#'
#' @title Three Inside
#'
#' @templateVar .title Three Inside
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun three_inside
#'
#' @template description
#'
#' @returns
#' \describe{
#'  \item{three_inside}{1 for bullish, -1 for bearish and 0 for no pattern}
#' }
three_inside <- function(
	x,
	cols,
	...
) {
	UseMethod(
		"three_inside"
	)
}

#' @export
#'
#' @usage NULL
#'
#' @rdname three_inside
#' @aliases three_inside
CDL3INSIDE <- three_inside

#' @usage NULL
#' @aliases three_inside
#' @export
three_inside.default <- function(
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
			"impl_ta_CDL3INSIDE",
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
	colnames(x) <- "three_inside"

	## return value
	return(x)
}

#' @usage NULL
#' @aliases three_inside
#' @export
three_inside.data.frame <- function(
	x,
	cols,
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases three_inside
#' @export
three_inside.matrix <- function(
	x,
	cols,
	...
) {
	as.matrix(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases three_inside
#' @export
three_inside.plotly <- function(
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
	.indicator <- three_inside.default(
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
		pattern_name = "Three Inside"
	)

	.plotting_environment$main
}
