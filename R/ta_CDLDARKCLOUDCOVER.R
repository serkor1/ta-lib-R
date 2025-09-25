#' @export
#' @family Pattern Recognition
#'
#' @title Dark Cloud Cover
#'
#' @templateVar .title Dark Cloud Cover
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun dark_cloud_cover
#'
#' @template description
#'
#' @returns
#' \describe{
#'  \item{dark_cloud_cover}{1 for bullish, -1 for bearish and 0 for no pattern}
#' }
dark_cloud_cover <- function(
	x,
	cols,
	eps = 0,
	...
) {
	UseMethod(
		"dark_cloud_cover"
	)
}

#' @usage NULL
#' @aliases dark_cloud_cover
#' @export
CDLDARKCLOUDCOVER <- dark_cloud_cover

#' @usage NULL
#' @aliases dark_cloud_cover
#' @export
dark_cloud_cover.default <- function(
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
			"impl_ta_CDLDARKCLOUDCOVER",
			x[[1]],
			x[[2]],
			x[[3]],
			x[[4]],
			as.double(eps),
			as.logical(
				getOption("talib.normalize", TRUE)
			)
		)
	)

	## set column names
	colnames(x) <- "dark_cloud_cover"

	## return value
	return(x)
}

#' @usage NULL
#' @aliases dark_cloud_cover
#' @export
dark_cloud_cover.data.frame <- function(
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
#' @aliases dark_cloud_cover
#' @export
dark_cloud_cover.matrix <- function(
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
#' @aliases dark_cloud_cover
#' @export
dark_cloud_cover.plotly <- function(
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
	.indicator <- dark_cloud_cover.default(
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
		pattern_name = "Dark Cloud Cover"
	)

	.plotting_environment$main
}
