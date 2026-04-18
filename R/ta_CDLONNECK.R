#' @export
#' @family Pattern Recognition
#'
#' @title On-Neck
#' @templateVar .title On-Neck
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun on_neck
#' @templateVar .family Pattern Recognition
#' @templateVar .formula ~open + high + low + close
#'
#' @returns
#' An object of same [class] and [length] of `x`:
#'
#' \describe{
#'  \item{CDLONNECK}{[integer]}
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
on_neck <- function(
	x,
	cols,
	na.bridge = FALSE,
	...
) {
	UseMethod("on_neck")
}

#' @export
#' @usage NULL
#' @rdname on_neck
#'
#' @aliases on_neck
CDLONNECK <- on_neck

#' @usage NULL
#' @aliases on_neck
#'
#' @export
on_neck.default <- function(
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
			C_impl_ta_CDLONNECK,
			constructed_series[[1]],
			constructed_series[[2]],
			constructed_series[[3]],
			constructed_series[[4]],
			normalize,
			as.logical(na.bridge)
		)
	)

	## add column name
	colnames(x) <- "CDLONNECK"

	## readd rownames
	set_rownames(x, x_names)

	## return indicator
	x
}

#' @usage NULL
#' @aliases on_neck
#'
#' @export
on_neck.data.frame <- function(
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
#' @aliases on_neck
#'
#' @export
on_neck.matrix <- function(
	x,
	cols,
	na.bridge = FALSE,
	...
) {
	NextMethod()
}

#' @usage NULL
#' @aliases on_neck
#'
#' @export
on_neck.plotly <- function(
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
	constructed_indicator <- on_neck(
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
		pattern_name = "on_neck",
		agnostic = FALSE
	)
	state[["main"]] <- plotly_object

	plotly_object
}


#' @usage NULL
#' @aliases on_neck
#'
#' @export
on_neck.ggplot <- function(
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
	constructed_indicator <- on_neck(
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
		pattern_name = "on_neck",
		agnostic = FALSE
	)
	state[["main"]] <- ggplot_object

	ggplot_object
}
