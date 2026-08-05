#' @export
#' @family Pattern Recognition
#'
#' @title Three Advancing White Soldiers
#' @templateVar .title Three Advancing White Soldiers
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun three_white_soldiers
#' @templateVar .family Pattern Recognition
#' @templateVar .formula ~open + high + low + close
#'
#' @returns
#' An object of same [class] and [length] of `x`:
#'
#' \describe{
#'  \item{CDL3WHITESOLDIERS}{[integer]}
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
three_white_soldiers <- function(
	x,
	cols,
	na.bridge = FALSE,
	...
) {
	UseMethod("three_white_soldiers")
}

#' @export
#' @usage NULL
#' @rdname three_white_soldiers
#'
#' @aliases three_white_soldiers
CDL3WHITESOLDIERS <- three_white_soldiers

#' @export
#' @usage NULL
#' @rdname three_white_soldiers
#'
#' @aliases three_white_soldiers
threeWhiteSoldiers <- three_white_soldiers

#' @usage NULL
#' @aliases three_white_soldiers
#'
#' @export
three_white_soldiers.default <- function(
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
		x = x,
		formula.default = ~ open + high + low + close,
		formula = cols,
		...
	)

	## extract rownames
	## for later attachment
	x_names <- index(constructed_series)

	## calculate indicator and
	## return as data.frame
	x <- .Call(
		C_impl_ta_CDL3WHITESOLDIERS,
		constructed_series[[1]],
		constructed_series[[2]],
		constructed_series[[3]],
		constructed_series[[4]],
		normalize,
		as.logical(na.bridge)
	)

	## add column name
	colnames(x) <- "CDL3WHITESOLDIERS"

	## readd rownames
	set_index(x, x_names)

	## return indicator
	x
}

#' @usage NULL
#' @aliases three_white_soldiers
#'
#' @export
three_white_soldiers.data.frame <- function(
	x,
	cols,
	na.bridge = FALSE,
	...
) {
	as.data.frame(
		three_white_soldiers.default(
			x = x,
			cols = cols,
			na.bridge = na.bridge,
			...
		)
	)
}

#' @usage NULL
#' @aliases three_white_soldiers
#'
#' @export
three_white_soldiers.matrix <- function(
	x,
	cols,
	na.bridge = FALSE,
	...
) {
	as.matrix(
		three_white_soldiers.default(
			x = x,
			cols = cols,
			na.bridge = na.bridge,
			...
		)
	)
}

#' @usage NULL
#' @aliases three_white_soldiers
#'
#' @export
three_white_soldiers.xts <- function(
	x,
	cols,
	na.bridge = FALSE,
	...
) {
	assert_xts()

	as.xts(
		three_white_soldiers.default(
			x = x,
			cols = cols,
			na.bridge = na.bridge,
			...
		)
	)
}


#' @usage NULL
CDL3WHITESOLDIERS_lookback <- threeWhiteSoldiers_lookback <- three_white_soldiers_lookback <- function(
	x,
	cols,
	na.bridge = FALSE,
	...
) {
	.Call(
		C_impl_ta_CDL3WHITESOLDIERS_lookback
	)
}

#' @usage NULL
#' @aliases three_white_soldiers
#'
#' @export
three_white_soldiers.plotly <- function(
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
		formula.default = ~ open + high + low + close,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- three_white_soldiers(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		na.bridge = na.bridge
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
		pattern_name = "three_white_soldiers",
		agnostic = FALSE
	)
	state[["main"]] <- plotly_object

	plotly_object
}

#' @usage NULL
#' @aliases three_white_soldiers
#'
#' @export
three_white_soldiers.ggplot <- function(
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
		formula.default = ~ open + high + low + close,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- three_white_soldiers(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		na.bridge = na.bridge
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
		pattern_name = "three_white_soldiers",
		agnostic = FALSE
	)
	state[["main"]] <- ggplot_object

	ggplot_object
}
