#' @export
#' @family Pattern Recognition
#'
#' @title Hikkake Modified
#' @templateVar .title Hikkake Modified
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun hikakke_mod
#' @templateVar .family Pattern Recognition
#' @templateVar .formula ~open + high + low + close
#'
#' @returns
#' An object of same [class] and [length] of `x`:
#'
#' \describe{
#'  \item{CDLHIKKAKEMOD}{[integer]}
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
hikakke_mod <- function(
	x,
	cols,
	na.bridge = FALSE,
	...
) {
	UseMethod("hikakke_mod")
}

#' @export
#' @usage NULL
#' @rdname hikakke_mod
#'
#' @aliases hikakke_mod
CDLHIKKAKEMOD <- hikakke_mod

#' @usage NULL
#' @aliases hikakke_mod
#'
#' @export
hikakke_mod.default <- function(
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
			C_impl_ta_CDLHIKKAKEMOD,
			constructed_series[[1]],
			constructed_series[[2]],
			constructed_series[[3]],
			constructed_series[[4]],
			normalize,
			as.logical(na.bridge)
		)
	)

	## add column name
	colnames(x) <- "CDLHIKKAKEMOD"

	## readd rownames
	set_rownames(x, x_names)

	## return indicator
	x
}

#' @usage NULL
#' @aliases hikakke_mod
#'
#' @export
hikakke_mod.data.frame <- function(
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
#' @aliases hikakke_mod
#'
#' @export
hikakke_mod.matrix <- function(
	x,
	cols,
	na.bridge = FALSE,
	...
) {
	NextMethod()
}

#' @usage NULL
#' @aliases hikakke_mod
#'
#' @export
hikakke_mod.plotly <- function(
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
	constructed_indicator <- hikakke_mod(
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
		pattern_name = "hikakke_mod",
		agnostic = FALSE
	)
	state[["main"]] <- plotly_object

	plotly_object
}


#' @usage NULL
#' @aliases hikakke_mod
#'
#' @export
hikakke_mod.ggplot <- function(
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
	constructed_indicator <- hikakke_mod(
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
		pattern_name = "hikakke_mod",
		agnostic = FALSE
	)
	state[["main"]] <- ggplot_object

	ggplot_object
}
