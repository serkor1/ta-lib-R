#' @export
#' @family Pattern Recognition
#'
#' @title Separating Lines
#' @templateVar .title Separating Lines
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun separating_lines
#' @templateVar .family Cycle Indicator
#'
#' @returns
#' An object of same [class] and [length] of `x`:
#'
#' \describe{
#'  \item{CDLSEPARATINGLINES}{[integer]}
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
separating_lines <- function(
	x,
	cols,
	...
) {
	UseMethod("separating_lines")
}

#' @export
#' @usage NULL
#' @rdname separating_lines
#'
#' @aliases separating_lines
CDLSEPARATINGLINES <- separating_lines

#' @usage NULL
#' @aliases separating_lines
#'
#' @export
separating_lines.default <- function(
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
			"impl_ta_CDLSEPARATINGLINES",
			constructed_series[[1]],
			constructed_series[[2]],
			constructed_series[[3]],
			constructed_series[[4]],
			normalize
		)
	)

	## add column name
	colnames(x) <- "CDLSEPARATINGLINES"

	## readd rownames
	set_rownames(x, x_names)

	## return indicator
	x
}

#' @usage NULL
#' @aliases separating_lines
#'
#' @export
separating_lines.data.frame <- function(
	x,
	cols,
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases separating_lines
#'
#' @export
separating_lines.matrix <- function(
	x,
	cols,
	...
) {
	as.matrix(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases separating_lines
#'
#' @export
separating_lines.plotly <- function(
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
	constructed_indicator <- separating_lines(
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
		pattern_name = "separating_lines",
		agnostic = FALSE
	)

	plotly_object
}
