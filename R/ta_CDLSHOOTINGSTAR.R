#' @export
#' @family Pattern Recognition
#'
#' @title Shooting Star
#' @templateVar .title Shooting Star
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun shooting_star
#' @templateVar .family Pattern Recognition
#' @templateVar .formula ~open + high + low + close
#'
#' @returns
#' An object of same [class] and [length] of `x`:
#'
#' \describe{
#'  \item{CDLSHOOTINGSTAR}{[integer]}
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
shooting_star <- function(
	x,
	cols,
	na.ignore = FALSE,
	...
) {
	UseMethod("shooting_star")
}

#' @export
#' @usage NULL
#' @rdname shooting_star
#'
#' @aliases shooting_star
CDLSHOOTINGSTAR <- shooting_star

#' @usage NULL
#' @aliases shooting_star
#'
#' @export
shooting_star.default <- function(
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
			"impl_ta_CDLSHOOTINGSTAR",
			constructed_series[[1]],
			constructed_series[[2]],
			constructed_series[[3]],
			constructed_series[[4]],
			normalize,
			as.logical(na.ignore)
		)
	)

	## add column name
	colnames(x) <- "CDLSHOOTINGSTAR"

	## readd rownames
	set_rownames(x, x_names)

	## return indicator
	x
}

#' @usage NULL
#' @aliases shooting_star
#'
#' @export
shooting_star.data.frame <- function(
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
#' @aliases shooting_star
#'
#' @export
shooting_star.matrix <- function(
	x,
	cols,
	na.ignore = FALSE,
	...
) {
	NextMethod()
}

#' @usage NULL
#' @aliases shooting_star
#'
#' @export
shooting_star.plotly <- function(
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
	constructed_indicator <- shooting_star(
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
		pattern_name = "shooting_star",
		agnostic = TRUE
	)

	plotly_object
}
