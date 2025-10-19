#' @export
#' @family Pattern Recognition
#'
#' @title Hikkake Modified
#'
#' @templateVar .title Hikkake Modified
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun hikakke_mod
#'
#' @template description
#'
#' @returns
#' \describe{
#'  \item{hikakke_mod}{1 for bullish, -1 for bearish and 0 for no pattern}
#' }
hikakke_mod <- function(
	x,
	cols,
	...
) {
	UseMethod(
		"hikakke_mod"
	)
}

#' @export
#'
#' @usage NULL
#'
#' @rdname hikakke_mod
#' @aliases hikakke_mod
CDLHIKKAKEMOD <- hikakke_mod

#' @usage NULL
#' @aliases hikakke_mod
#' @export
hikakke_mod.default <- function(
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
			"impl_ta_CDLHIKKAKEMOD",
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
	colnames(x) <- "hikakke_mod"

	## return value
	return(x)
}

#' @usage NULL
#' @aliases hikakke_mod
#' @export
hikakke_mod.data.frame <- function(
	x,
	cols,
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases hikakke_mod
#' @export
hikakke_mod.matrix <- function(
	x,
	cols,
	...
) {
	as.matrix(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases hikakke_mod
#' @export
hikakke_mod.plotly <- function(
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
	.indicator <- hikakke_mod.default(
		x = OHLC,
		cols = ~ open + high + low + close
	)

	## add x-axis conditional on whether
	## the data have been subsetted or not
	.indicator$idx <- add_idx(
		OHLC
	)

	## chart patterns
	.plotting_environment$main <- pattern(
		p = .plotting_environment$main,
		x = .indicator,
		high = OHLC[[2]],
		low = OHLC[[3]],
		pattern_name = "hikakke_mod"
	)

	.plotting_environment$main
}
