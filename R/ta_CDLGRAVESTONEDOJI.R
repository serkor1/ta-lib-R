#' @export
#' @family Pattern Recognition
#'
#' @title Gravestone Doji
#' @templateVar .title Gravestone Doji
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun gravestone_doji
#' @templateVar .family Pattern Recognition
#' @templateVar .formula ~open + high + low + close
#'
#' @returns
#' An object of same [class] and [length] of `x`:
#'
#' \describe{
#'  \item{CDLGRAVESTONEDOJI}{[integer]}
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
gravestone_doji <- function(
	x,
	cols,
	na.ignore = FALSE,
	...
) {
	UseMethod("gravestone_doji")
}

#' @export
#' @usage NULL
#' @rdname gravestone_doji
#'
#' @aliases gravestone_doji
CDLGRAVESTONEDOJI <- gravestone_doji

#' @usage NULL
#' @aliases gravestone_doji
#'
#' @export
gravestone_doji.default <- function(
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
			"impl_ta_CDLGRAVESTONEDOJI",
			constructed_series[[1]],
			constructed_series[[2]],
			constructed_series[[3]],
			constructed_series[[4]],
			normalize,
			as.logical(na.ignore)
		)
	)

	## add column name
	colnames(x) <- "CDLGRAVESTONEDOJI"

	## readd rownames
	set_rownames(x, x_names)

	## return indicator
	x
}

#' @usage NULL
#' @aliases gravestone_doji
#'
#' @export
gravestone_doji.data.frame <- function(
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
#' @aliases gravestone_doji
#'
#' @export
gravestone_doji.matrix <- function(
	x,
	cols,
	na.ignore = FALSE,
	...
) {
	NextMethod()
}

#' @usage NULL
#' @aliases gravestone_doji
#'
#' @export
gravestone_doji.plotly <- function(
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
	constructed_indicator <- gravestone_doji(
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
		pattern_name = "gravestone_doji",
		agnostic = FALSE
	)

	plotly_object
}


#' @usage NULL
#' @aliases gravestone_doji
#'
#' @export
gravestone_doji.ggplot <- function(
	x,
	cols,
	na.ignore = FALSE,
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
	constructed_indicator <- gravestone_doji(
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
	ggplot_object <- .chart_environment[["main"]] <- pattern_gg(
		p = .chart_environment[["main"]],
		x = constructed_indicator,
		high = constructed_series[[2]],
		low = constructed_series[[3]],
		pattern_name = "gravestone_doji",
		agnostic = FALSE
	)

	ggplot_object
}
