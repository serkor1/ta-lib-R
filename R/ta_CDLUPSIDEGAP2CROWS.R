#' @export
#' @family Pattern Recognition
#'
#' @title Upside Gap Two Crows
#'
#' @templateVar .title Upside Gap Two Crows
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun upside_gap_2_crows
#'
#' @template description
#'
#' @returns
#' \describe{
#'  \item{upside_gap_2_crows}{-1 for bearish reversal, 0 for no pattern}
#' }
upside_gap_2_crows <- function(x, cols, ...) {
	UseMethod("upside_gap_2_crows")
}

#' @export
#' @usage NULL
#' @rdname upside_gap_2_crows
#' @aliases upside_gap_2_crows
CDLUPSIDEGAP2CROWS <- upside_gap_2_crows

#' @usage NULL
#' @aliases upside_gap_2_crows
#' @export
upside_gap_2_crows.default <- function(x, cols, ...) {
	if (!missing(cols)) {
		assert(
			is.formula(cols),
			paste0(
				"'cols' has to be <",
				class(~s),
				">. Got <",
				class(cols),
				">."
			)
		)
		assert(
			length(all.vars(cols)) == 4,
			paste0(
				"'cols' has to be length 4. Got length ",
				length(all.vars(cols))
			)
		)
	}
	OHLC <- series(
		x = cols,
		default = ~ open + high + low + close,
		data = x,
		...
	)
	x <- as.data.frame(.Call(
		"impl_ta_CDLUPSIDEGAP2CROWS",
		OHLC[[1]],
		OHLC[[2]],
		OHLC[[3]],
		OHLC[[4]],
		as.logical(getOption("talib.normalize", TRUE))
	))
	colnames(x) <- "upside_gap_2_crows"
	x
}

#' @usage NULL
#' @aliases upside_gap_2_crows
#' @export
upside_gap_2_crows.data.frame <- function(x, cols, ...) {
	as.data.frame(NextMethod())
}

#' @usage NULL
#' @aliases upside_gap_2_crows
#' @export
upside_gap_2_crows.matrix <- function(x, cols, ...) as.matrix(NextMethod())

#' @usage NULL
#' @aliases upside_gap_2_crows
#' @export
upside_gap_2_crows.plotly <- function(x, cols, ...) {
	OHLC <- series(
		x = x,
		formula = cols,
		default = ~ open + high + low + close,
		...
	)
	.indicator <- upside_gap_2_crows.default(
		x = OHLC,
		cols = ~ open + high + low + close
	)

	## add x-axis conditional on whether
	## the data have been subsetted or not
	.indicator$idx <- add_idx(
		OHLC
	)

	.plotting_environment$main <- pattern(
		.plotting_environment$main,
		.indicator,
		OHLC[[2]],
		OHLC[[3]],
		"upside_gap_2_crows"
	)
	.plotting_environment$main
}
