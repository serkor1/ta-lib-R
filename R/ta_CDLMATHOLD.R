#' @export
#' @family Pattern Recognition
#'
#' @title Mat Hold
#' @templateVar .title Mat Hold
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun mat_hold
#' @templateVar .family Pattern Recognition
#' @templateVar .formula ~open + high + low + close
#'
#' @returns
#' An object of same [class] and [length] of `x`:
#'
#' \describe{
#'  \item{CDLMATHOLD}{[integer]}
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
mat_hold <- function(
	x,
	cols,
	penetration = 0.5,
	na.bridge = FALSE,
	...
) {
	UseMethod("mat_hold")
}

#' @export
#' @usage NULL
#' @rdname mat_hold
#'
#' @aliases mat_hold
CDLMATHOLD <- mat_hold

#' @export
#' @usage NULL
#' @rdname mat_hold
#'
#' @aliases mat_hold
matHold <- mat_hold

#' @usage NULL
#' @aliases mat_hold
#'
#' @export
mat_hold.default <- function(
	x,
	cols,
	penetration = 0.5,
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
		C_impl_ta_CDLMATHOLD,
		constructed_series[[1]],
		constructed_series[[2]],
		constructed_series[[3]],
		constructed_series[[4]],
		as.double(penetration),
		normalize,
		as.logical(na.bridge)
	)

	## add column name
	colnames(x) <- "CDLMATHOLD"

	## readd rownames
	set_index(x, x_names)

	## return indicator
	x
}

#' @usage NULL
#' @aliases mat_hold
#'
#' @export
mat_hold.data.frame <- function(
	x,
	cols,
	penetration = 0.5,
	na.bridge = FALSE,
	...
) {
	as.data.frame(
		mat_hold.default(
			x = x,
			cols = cols,
			penetration = penetration,
			na.bridge = na.bridge,
			...
		)
	)
}

#' @usage NULL
#' @aliases mat_hold
#'
#' @export
mat_hold.matrix <- function(
	x,
	cols,
	penetration = 0.5,
	na.bridge = FALSE,
	...
) {
	as.matrix(
		mat_hold.default(
			x = x,
			cols = cols,
			penetration = penetration,
			na.bridge = na.bridge,
			...
		)
	)
}

#' @usage NULL
#' @aliases mat_hold
#'
#' @export
mat_hold.xts <- function(
	x,
	cols,
	penetration = 0.5,
	na.bridge = FALSE,
	...
) {
	as.xts(
		mat_hold.default(
			x = x,
			cols = cols,
			penetration = penetration,
			na.bridge = na.bridge,
			...
		)
	)
}


#' @usage NULL
CDLMATHOLD_lookback <- matHold_lookback <- mat_hold_lookback <- function(
	x,
	cols,
	penetration = 0.5,
	na.bridge = FALSE,
	...
) {
	.Call(
		C_impl_ta_CDLMATHOLD_lookback,
		as.double(penetration)
	)
}

#' @usage NULL
#' @aliases mat_hold
#'
#' @export
mat_hold.plotly <- function(
	x,
	cols,
	penetration = 0.5,
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
	constructed_indicator <- mat_hold(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		penetration = penetration,
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
		pattern_name = "mat_hold",
		agnostic = FALSE
	)
	state[["main"]] <- plotly_object

	plotly_object
}

#' @usage NULL
#' @aliases mat_hold
#'
#' @export
mat_hold.ggplot <- function(
	x,
	cols,
	penetration = 0.5,
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
	constructed_indicator <- mat_hold(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		penetration = penetration,
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
		pattern_name = "mat_hold",
		agnostic = FALSE
	)
	state[["main"]] <- ggplot_object

	ggplot_object
}
