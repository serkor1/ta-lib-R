#' @export
#' @family Pattern Recognition
#'
#' @title Hammer
#' @templateVar .title Hammer
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun hammer
#' @templateVar .family Cycle Indicator
#' @templateVar .formula ~close+fisk
#'
#' @returns
#' An object of same [class] and [length] of `x`:
#'
#' \describe{
#'  \item{CDLHAMMER}{[integer]}
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
hammer <- function(
	x,
	cols,
	...
) {
	UseMethod("hammer")
}

#' @export
#' @usage NULL
#' @rdname hammer
#'
#' @aliases hammer
CDLHAMMER <- hammer

#' @usage NULL
#' @aliases hammer
#'
#' @export
hammer.default <- function(
	x,
	cols,
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
			"impl_ta_CDLHAMMER",
			constructed_series[[1]],
			constructed_series[[2]],
			constructed_series[[3]],
			constructed_series[[4]],
			normalize
		)
	)

	## add column name
	colnames(x) <- "CDLHAMMER"

	## readd rownames
	set_rownames(x, x_names)

	## return indicator
	x
}

#' @usage NULL
#' @aliases hammer
#'
#' @export
hammer.data.frame <- function(
	x,
	cols,
	...
) {
	map_dfr(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases hammer
#'
#' @export
hammer.matrix <- function(
	x,
	cols,
	...
) {
	NextMethod()
}

#' @usage NULL
#' @aliases hammer
#'
#' @export
hammer.plotly <- function(
	x,
	cols,
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
	constructed_indicator <- hammer(
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
	plotly_object <- .plotting_environment[["main"]] <- pattern(
		p = .plotting_environment[["main"]],
		x = constructed_indicator,
		high = constructed_series[[2]],
		low = constructed_series[[3]],
		pattern_name = "hammer",
		agnostic = FALSE
	)

	plotly_object
}
