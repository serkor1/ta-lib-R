#' @export
#' @family Overlap Studies
#'
#' @title Hilbert Transform - Instantaneous Trendline
#' @templateVar .title Hilbert Transform - Instantaneous Trendline
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun trendline
#' @templateVar .family Overlap Studies
#' @templateVar .formula ~close
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
#'
#' @template returns
trendline <- function(
	x,
	cols,
	na.bridge = FALSE,
	...
) {
	UseMethod("trendline")
}

#' @export
#' @usage NULL
#' @rdname trendline
#'
#' @aliases trendline
HT_TRENDLINE <- trendline

#' @usage NULL
#' @aliases trendline
#'
#' @export
trendline.default <- function(
	x,
	cols,
	na.bridge = FALSE,
	...
) {
	## validate 'cols'-argument
	## if explicitly passed
	if (!missing(cols)) {
		assert_formula(cols)
	}

	## construct series
	## from input
	constructed_series <- series(
		x = x,
		formula = cols,
		formula.default = ~close,
		...
	)

	## extract rownames
	## for later attachment
	x_names <- index(constructed_series)

	## calculate indicator and
	## return as data.frame
	x <- .Call(
		C_impl_ta_HT_TRENDLINE,
		constructed_series[[1]],
		as.logical(na.bridge)
	)

	## readd rownames
	set_index(x, x_names)

	## return indicator
	x
}

#' @usage NULL
#' @aliases trendline
#'
#' @export
trendline.data.frame <- function(
	x,
	cols,
	na.bridge = FALSE,
	...
) {
	as.data.frame(
		trendline.default(
			x = x,
			cols = cols,
			na.bridge = na.bridge,
			...
		)
	)
}

#' @usage NULL
#' @aliases trendline
#'
#' @export
trendline.matrix <- function(
	x,
	cols,
	na.bridge = FALSE,
	...
) {
	as.matrix(
		trendline.default(
			x = x,
			cols = cols,
			na.bridge = na.bridge,
			...
		)
	)
}

#' @usage NULL
#' @aliases trendline
#'
#' @export
trendline.xts <- function(
	x,
	cols,
	na.bridge = FALSE,
	...
) {
	assert_xts()

	as.xts(
		trendline.default(
			x = x,
			cols = cols,
			na.bridge = na.bridge,
			...
		)
	)
}

#' @usage NULL
HT_TRENDLINE_lookback <- trendline_lookback <- function(
	x,
	cols,
	na.bridge = FALSE,
	...
) {
	.Call(
		C_impl_ta_HT_TRENDLINE_lookback
	)
}

#' @usage NULL
#' @aliases trendline
#'
#' @export
trendline.numeric <- function(
	x,
	cols,
	na.bridge = FALSE,
	...
) {
	## warn if 'cols' have been
	## passed just to make sure
	## the user knows its not possible
	## or relevant
	if (!missing(cols)) {
		warning("'cols' is passed but is unused for vectors.")
	}

	if (...length()) {
		warning("'...' is passed but is unused for vectors.")
	}

	## pass the argument directly
	## to 'C'
	x <- .Call(
		C_impl_ta_HT_TRENDLINE,
		as.double(x),
		as.logical(na.bridge)
	)

	if (dim(x)[2] == 1L) {
		dim(x) <- NULL
	}
	class(x) <- NULL

	x
}

#' @usage NULL
#' @aliases trendline
#'
#' @export
trendline.plotly <- function(
	x,
	cols,
	na.bridge = FALSE,
	## splice:optional-plotly:start
	## splice:optional-plotly:end
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
		formula.default = ~close,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- trendline(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		na.bridge = TRUE
	)

	## add conditional idx
	constructed_indicator[["idx"]] <- add_idx(
		constructed_series
	)

	## construct {plotly}-object
	## splice:plotly-assembly:start
	name <- "Trendline"
	traces <- list(
		list(y = ~HT_TRENDLINE, name = "Trendline")
	)
	## splice:plotly-assembly:end

	state <- .chart_state()
	plotly_object <- build_plotly(
		init = state[["main"]],
		traces = traces,
		decorators = list(),
		name = get0(
			x = "name",
			ifnotfound = NULL
		),
		data = constructed_indicator
	)
	state[["main"]] <- plotly_object

	plotly_object
}

#' @usage NULL
#' @aliases trendline
#'
#' @export
trendline.ggplot <- function(
	x,
	cols,
	na.bridge = FALSE,
	## splice:optional-ggplot:start
	## splice:optional-ggplot:end
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
		formula.default = ~close,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- trendline(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		na.bridge = TRUE
	)

	## add conditional idx
	constructed_indicator[["idx"]] <- add_idx(
		constructed_series
	)

	## construct {ggplot2}-object
	## splice:ggplot-assembly:start
	layers <- lapply(
		setdiff(colnames(constructed_indicator), "idx"),
		function(col) list(y = col)
	)
	name <- "Trendline"
	## splice:ggplot-assembly:end

	state <- .chart_state()
	ggplot_object <- build_ggplot(
		init = state[["main"]],
		layers = layers,
		decorators = list(),
		name = get0(
			x = "name",
			ifnotfound = NULL
		),
		data = constructed_indicator
	)
	state[["main"]] <- ggplot_object

	ggplot_object
}
