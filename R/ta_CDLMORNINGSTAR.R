#' @export
#' @family Pattern Recognition
#'
#' @title Morning Star
#' @templateVar .title Morning Star
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun morning_star
#' @templateVar .family Pattern Recognition
#' @templateVar .formula ~open + high + low + close
#'
#' @returns
#' An object of same [class] and [length] of `x`:
#'
#' \describe{
#'  \item{CDLMORNINGSTAR}{[integer]}
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
morning_star <- function(
	x,
	cols,
	eps = 0,
	na.rm = FALSE,
	...
) {
	UseMethod("morning_star")
}

#' @export
#' @usage NULL
#' @rdname morning_star
#'
#' @aliases morning_star
CDLMORNINGSTAR <- morning_star

#' @usage NULL
#' @aliases morning_star
#'
#' @export
morning_star.default <- function(
	x,
	cols,
	eps = 0,
	na.rm = FALSE,
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
			"impl_ta_CDLMORNINGSTAR",
			constructed_series[[1]],
			constructed_series[[2]],
			constructed_series[[3]],
			constructed_series[[4]],
			eps,
			normalize,
			as.logical(na.rm)
		)
	)

	## add column name
	colnames(x) <- "CDLMORNINGSTAR"

	## readd rownames
	set_rownames(x, x_names)

	## return indicator
	x
}

#' @usage NULL
#' @aliases morning_star
#'
#' @export
morning_star.data.frame <- function(
	x,
	cols,
	eps = 0,
	na.rm = FALSE,
	...
) {
	map_dfr(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases morning_star
#'
#' @export
morning_star.matrix <- function(
	x,
	cols,
	eps = 0,
	na.rm = FALSE,
	...
) {
	NextMethod()
}

#' @usage NULL
#' @aliases morning_star
#'
#' @export
morning_star.plotly <- function(
	x,
	cols,
	eps = 0,
	na.rm = FALSE,
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
	constructed_indicator <- morning_star(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		eps = eps
	)

	## add conditional idx
	constructed_indicator[["idx"]] <- add_idx(
		constructed_series
	)

	## construct {plotly}-object
	plotly_object <- .plotting_environment[["main"]] <- pattern(
		p = .plotting_environment[["main"]],
		x = constructed_indicator,
		high = constructed_series[[2]],
		low = constructed_series[[3]],
		pattern_name = "morning_star",
		agnostic = FALSE
	)

	plotly_object
}
