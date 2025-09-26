#' @export
#' @family Pattern Recognition
#'
#' @title Three Stars in the South
#'
#' @templateVar .title Three Stars in the South
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun three_stars_in_the_south
#'
#' @template description
#'
#' @returns
#' \describe{
#'  \item{three_stars_in_the_south}{1 for bullish, -1 for bearish and 0 for no pattern}
#' }
three_stars_in_the_south <- function(
	x,
	cols,
	...
) {
	UseMethod(
		"three_stars_in_the_south"
	)
}

#' @usage NULL
#' @aliases three_stars_in_the_south
#' @export
CDL3STARSINSOUTH <- three_stars_in_the_south

#' @usage NULL
#' @aliases three_stars_in_the_south
#' @export
three_stars_in_the_south.default <- function(
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
			"impl_ta_CDL3STARSINSOUTH",
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
	colnames(x) <- "three_stars_in_the_south"

	## return value
	return(x)
}

#' @usage NULL
#' @aliases three_stars_in_the_south
#' @export
three_stars_in_the_south.data.frame <- function(
	x,
	cols,
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases three_stars_in_the_south
#' @export
three_stars_in_the_south.matrix <- function(
	x,
	cols,
	...
) {
	as.matrix(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases three_stars_in_the_south
#' @export
three_stars_in_the_south.plotly <- function(
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
	.indicator <- three_stars_in_the_south.default(
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
		pattern_name = "Three Stars in the South"
	)

	.plotting_environment$main
}
