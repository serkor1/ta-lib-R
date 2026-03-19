#' @export
#' @family Pattern Recognition
#'
#' @title Up/Down-gap side-by-side white lines
#' @templateVar .title Up/Down-gap side-by-side white lines
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun gaps_side_white
#' @templateVar .family Pattern Recognition
#' @templateVar .formula ~open + high + low + close
#'
#' @returns
#' An object of same [class] and [length] of `x`:
#'
#' \describe{
#'  \item{CDLGAPSIDESIDEWHITE}{[integer]}
#' }
#'
#' Pattern codes depend on `options(talib.normalize)`:
#'
#' * If `TRUE`: `1` = identified pattern; `-1` = identified bearish pattern.
#' * If `FALSE`: `100` = identified pattern; `-100` = identified bearish pattern.
#' * `0` = no pattern.
#'
#' @template description
#' @template candlestick
gaps_side_white <- function(
	x,
	cols,
	na.ignore = FALSE,
	...
) {
	UseMethod("gaps_side_white")
}

#' @export
#' @usage NULL
#' @rdname gaps_side_white
#'
#' @aliases gaps_side_white
CDLGAPSIDESIDEWHITE <- gaps_side_white

#' @usage NULL
#' @aliases gaps_side_white
#'
#' @export
gaps_side_white.default <- function(
	x,
	cols,
	na.ignore = FALSE,
	...
) {
	## get candlestick pattern
	## options
	##
	## NOTE: this adds an overhead
	##       of ~60% (from 50 microseconds to 80 microseconds) it needs to be set outside of the function without bloating the number of functions
	candlestick_setting()

	## get normalization option
	normalize <- as.logical(
		getOption("talib.normalize", TRUE)
	)

	## validate 'cols'-argument
	## if explicitly passed
	if (!missing(cols)) {
		assert_formula(cols)
	}

	## construct series
	## from input
	constructed_series <- series(
		x = cols,
		default = ~ open + high + low + close,
		data = x,
		...
	)

	## extract rownames
	## for later attachment
	x_names <- rownames(constructed_series)

	## calculate indicator and
	## return as data.frame
	x <- as.matrix(
		.Call(
			"impl_ta_CDLGAPSIDESIDEWHITE",
			constructed_series[[1]],
			constructed_series[[2]],
			constructed_series[[3]],
			constructed_series[[4]],
			normalize,
			as.logical(na.ignore)
		)
	)

	## add column name
	colnames(x) <- "CDLGAPSIDESIDEWHITE"

	## readd rownames
	set_rownames(x, x_names)

	## return indicator
	x
}

#' @usage NULL
#' @aliases gaps_side_white
#'
#' @export
gaps_side_white.data.frame <- function(
	x,
	cols,
	na.ignore = FALSE,
	...
) {
	map_dfr(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases gaps_side_white
#'
#' @export
gaps_side_white.matrix <- function(
	x,
	cols,
	na.ignore = FALSE,
	...
) {
	NextMethod()
}

#' @usage NULL
#' @aliases gaps_side_white
#'
#' @export
gaps_side_white.plotly <- function(
	x,
	cols,
	na.ignore = FALSE,
	...
) {
	## check that input value
	## 'x' is <plotly>-object
	assert_plotly(x)

	## check that input value
	## 'cols' is a <formula>-objet
	if (!missing(cols)) {
		assert_formula(cols)
	}

	## construct series from
	## {plotly}-object
	constructed_series <- series(
		x = x,
		formula = cols,
		default = ~ open + high + low + close,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- gaps_side_white(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		)
	)

	## add conditional idx
	constructed_indicator[["idx"]] <- add_idx(
		constructed_series
	)

	## construct {plotly}-object
	plotly_object <- .chart_environment[["main"]] <- pattern(
		p = .chart_environment[["main"]],
		x = constructed_indicator,
		high = constructed_series[[2]],
		low = constructed_series[[3]],
		pattern_name = "gaps_side_white",
		agnostic = FALSE
	)

	plotly_object
}
