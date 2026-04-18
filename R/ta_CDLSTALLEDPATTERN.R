#' @export
#' @family Pattern Recognition
#'
#' @title Stalled Pattern
#' @templateVar .title Stalled Pattern
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun stalled_pattern
#' @templateVar .family Pattern Recognition
#' @templateVar .formula ~open + high + low + close
#'
#' @returns
#' An object of same [class] and [length] of `x`:
#'
#' \describe{
#'  \item{CDLSTALLEDPATTERN}{[integer]}
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
stalled_pattern <- function(
	x,
	cols,
	na.bridge = FALSE,
	...
) {
	UseMethod("stalled_pattern")
}

#' @export
#' @usage NULL
#' @rdname stalled_pattern
#'
#' @aliases stalled_pattern
CDLSTALLEDPATTERN <- stalled_pattern

#' @usage NULL
#' @aliases stalled_pattern
#'
#' @export
stalled_pattern.default <- function(
	x,
	cols,
	na.bridge = FALSE,
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
			C_impl_ta_CDLSTALLEDPATTERN,
			constructed_series[[1]],
			constructed_series[[2]],
			constructed_series[[3]],
			constructed_series[[4]],
			normalize,
			as.logical(na.bridge)
		)
	)

	## add column name
	colnames(x) <- "CDLSTALLEDPATTERN"

	## readd rownames
	set_rownames(x, x_names)

	## return indicator
	x
}

#' @usage NULL
#' @aliases stalled_pattern
#'
#' @export
stalled_pattern.data.frame <- function(
	x,
	cols,
	na.bridge = FALSE,
	...
) {
	map_dfr(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases stalled_pattern
#'
#' @export
stalled_pattern.matrix <- function(
	x,
	cols,
	na.bridge = FALSE,
	...
) {
	NextMethod()
}

#' @usage NULL
#' @aliases stalled_pattern
#'
#' @export
stalled_pattern.plotly <- function(
	x,
	cols,
	na.bridge = FALSE,
	...
) {
	## check that input value
	## 'x' is <plotly>-object
	assert_plotly_object(x)

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
	constructed_indicator <- stalled_pattern(
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
	state <- .chart_state()
	plotly_object <- pattern_ly(
		p = state[["main"]],
		x = constructed_indicator,
		high = constructed_series[[2]],
		low = constructed_series[[3]],
		pattern_name = "stalled_pattern",
		agnostic = FALSE
	)
	state[["main"]] <- plotly_object

	plotly_object
}


#' @usage NULL
#' @aliases stalled_pattern
#'
#' @export
stalled_pattern.ggplot <- function(
	x,
	cols,
	na.bridge = FALSE,
	...
) {
	## check ggplot2 availability
	assert_ggplot2()

	## check that input value
	## 'cols' is a <formula>-objet
	if (!missing(cols)) {
		assert_formula(cols)
	}

	## construct series from
	## {ggplot}-object
	constructed_series <- series(
		x = x,
		formula = cols,
		default = ~ open + high + low + close,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- stalled_pattern(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		)
	)

	## add conditional idx
	constructed_indicator[["idx"]] <- add_idx(
		constructed_series
	)

	## construct {ggplot2}-object
	state <- .chart_state()
	ggplot_object <- pattern_gg(
		p = state[["main"]],
		x = constructed_indicator,
		high = constructed_series[[2]],
		low = constructed_series[[3]],
		pattern_name = "stalled_pattern",
		agnostic = FALSE
	)
	state[["main"]] <- ggplot_object

	ggplot_object
}
