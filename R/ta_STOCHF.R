#' @export
#' @family Momentum Indicators
#'
#' @title Stochastic Fast
#' @templateVar .title Stochastic Fast
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun fast_stochastic
#' @templateVar .family Momentum Indicators
#' @templateVar .formula ~high + low + close
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
#' @param fastKPeriod ([integer]). Time period for building the Fast-K line. Defaults to `5`.
#' @param fastDPeriod ([integer]). Smoothing for making the Fast-D line. Usually set to 3. Defaults to `3`.
#' @param fastDMa ([integer]). Type of Moving Average for Fast-D. Defaults to `0` ([SMA]). Can also be passed as talib::SMA.
#' @template returns
fast_stochastic <- function(
	x,
	cols,
	fastKPeriod = 5,
	fastDPeriod = 3,
	fastDMa = 0,
	na.bridge = FALSE,
	...) {
  UseMethod("fast_stochastic")
}

#' @export
#' @usage NULL
#' @rdname fast_stochastic
#'
#' @aliases fast_stochastic
STOCHF <- fast_stochastic

#' @usage NULL
#' @aliases fast_stochastic
#'
#' @export
fast_stochastic.default <- function(
	x,
	cols,
	fastKPeriod = 5,
	fastDPeriod = 3,
	fastDMa = 0,
	na.bridge = FALSE,
	...) {

	## validate 'cols'-argument
	## if explicitly passed
	if (!missing(cols)) {
		assert_formula(cols)
	}

	## construct series
	## from input
	constructed_series <- series(
		x = cols,
		default_formula = ~high + low + close,
		data = x,
		...
	)

	## extract rownames
	## for later attachment
	x_names <- rownames(constructed_series)

	## calculate indicator and
	## return as data.frame
	x <- .Call(
		C_impl_ta_STOCHF,
		constructed_series[[1]],
		constructed_series[[2]],
		constructed_series[[3]],
		as.integer(fastKPeriod),
		as.integer(fastDPeriod),
		as.maType(fastDMa),		
		as.logical(na.bridge)
	)

	## readd rownames
	set_rownames(x, x_names)

	## return indicator
	x
}

#' @usage NULL
#' @aliases fast_stochastic
#'
#' @export
fast_stochastic.data.frame <- function(
	x,
	cols,
	fastKPeriod = 5,
	fastDPeriod = 3,
	fastDMa = 0,
	na.bridge = FALSE,
	...
) {
	map_dfr(
		fast_stochastic.default(
			x = x,
			cols = cols,
			fastKPeriod = fastKPeriod,
			fastDPeriod = fastDPeriod,
			fastDMa = fastDMa,
			na.bridge = na.bridge,
			...
		)
	)

}

#' @usage NULL
#' @aliases fast_stochastic
#'
#' @export
fast_stochastic.matrix <- function(
	x,
	cols,
	fastKPeriod = 5,
	fastDPeriod = 3,
	fastDMa = 0,
	na.bridge = FALSE,
	...) {

	fast_stochastic.default(
			x = x,
			cols = cols ,
			fastKPeriod = fastKPeriod,
			fastDPeriod = fastDPeriod,
			fastDMa = fastDMa,
			na.bridge = na.bridge,
			...
		)
}

#' @usage NULL
STOCHF_lookback <- fast_stochastic_lookback <- function(
	x,
	cols,
	fastKPeriod = 5,
	fastDPeriod = 3,
	fastDMa = 0,
	na.bridge = FALSE,
	...
) {

	.Call(
		C_impl_ta_STOCHF_lookback,
		as.integer(fastKPeriod),
		as.integer(fastDPeriod),
		as.maType(fastDMa)
	)

}

#' @usage NULL
#' @aliases fast_stochastic
#'
#' @export
fast_stochastic.plotly <- function(
	x,
	cols,
	fastKPeriod = 5,
	fastDPeriod = 3,
	fastDMa = 0,
	na.bridge = FALSE,
	## splice:optional-plotly:start
	lower_bound = 20,
	upper_bound = 80,
	## splice:optional-plotly:end
	title,
	...) {

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
		default_formula = ~high + low + close,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- fast_stochastic(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		fastKPeriod = fastKPeriod,
			fastDPeriod = fastDPeriod,
			fastDMa = fastDMa,
		na.bridge = TRUE
	)

	## the constructed indicator
	## always returns excpected
	## columns which can be passed
	## down to add_last_values()
	values_to_extract <- colnames(constructed_indicator)

	## add conditional idx
	constructed_indicator[["idx"]] <- add_idx(
		constructed_series
	)

	## construct {plotly}-object
	## splice:plotly-assembly:start

	name <- sprintf("StochF(%d)", fastKPeriod)

	decorators <- list(
		function(p) add_limit_ly(p, y_range = c(0, 100))
	)

	traces <- list(
		plotly_line(lower_bound),
		plotly_line(upper_bound),
		list(y = ~FastK),
		list(y = ~FastD)
	)
	## splice:plotly-assembly:end

	plotly_object <- add_last_value_ly(
		build_plotly(
			init = plotly_init(),
			traces = traces,
			decorators = get0(
				x = "decorators",
				ifnotfound = list()
			),
			name = get0(
				x = "name",
				ifnotfound = NULL
			),
			data = constructed_indicator,
			title = if (missing(title)) {"Stochastic Fast"} else {title}
		),
		data = constructed_indicator[,values_to_extract, drop = FALSE],
		values_to_extract = values_to_extract
	)

	state <- .chart_state()
	state$sub <- c(state$sub, list(plotly_object))

	plotly_object
}

#' @usage NULL
#' @aliases fast_stochastic
#'
#' @export
fast_stochastic.ggplot <- function(
	x,
	cols,
	fastKPeriod = 5,
	fastDPeriod = 3,
	fastDMa = 0,
	na.bridge = FALSE,
	title,
	## splice:optional-ggplot:start
	## splice:optional-ggplot:end
	...) {

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
		default_formula = ~high + low + close,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- fast_stochastic(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		fastKPeriod = fastKPeriod,
			fastDPeriod = fastDPeriod,
			fastDMa = fastDMa,
		na.bridge = TRUE
	)

	## the constructed indicator
	## always returns expected
	## columns which can be passed
	## down to add_last_value_gg()
	values_to_extract <- colnames(constructed_indicator)

	## add conditional idx
	constructed_indicator[["idx"]] <- add_idx(
		constructed_series
	)

	## construct {ggplot2}-object
	## splice:ggplot-assembly:start
	decorators <- list(
		function(p) add_limit_gg(p, c(0, 100))
	)
	layers <- list(
		ggplot_line(20),
		ggplot_line(80),
		list(y = "FastK"),
		list(y = "FastD")
	)
	name <- sprintf("StochF(%d)", fastKPeriod)
	## splice:ggplot-assembly:end

	ggplot_object <- add_last_value_gg(
		build_ggplot(
			init = ggplot_init(),
			layers = layers,
			decorators = get0(
				x = "decorators",
				ifnotfound = list()
			),
			name = get0(
				x = "name",
				ifnotfound = NULL
			),
			data = constructed_indicator,
			title = if (missing(title)) {"Stochastic Fast"} else {title}
		),
		data = constructed_indicator[,values_to_extract, drop = FALSE],
		values_to_extract = values_to_extract,
		name = get0(x = "name", ifnotfound = NULL)
	)

	state <- .chart_state()
	state$sub <- c(state$sub, list(ggplot_object))

	ggplot_object
}
