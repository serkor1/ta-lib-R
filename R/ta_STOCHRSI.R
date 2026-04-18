#' @export
#' @family Momentum Indicator
#'
#' @title Stochastic Relative Strength Index
#' @templateVar .title Stochastic Relative Strength Index
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun stochastic_relative_strength_index
#' @templateVar .family Momentum Indicator
#' @templateVar .formula ~ high + low + close
#'
## splice:documentation:start
#' @param fastk ([integer]). Period for the fast-k line.
#' @param fastd ([list]). Period and Moving Average (MA) type for the fast-d line. [SMA] by default.
#' @param n_rsi ([integer]). Period for the [relative_strength_index].
## splice:documentation:end
#'
#' @template description
#' @template returns
stochastic_relative_strength_index <- function(
	x,
	cols,
	n = 14,
	n_rsi = 14,
	fastk = 5,
	fastd = SMA(n = 3),
	na.bridge = FALSE,
	...
) {
	UseMethod("stochastic_relative_strength_index")
}

#' @export
#' @usage NULL
#' @rdname stochastic_relative_strength_index
#'
#' @aliases stochastic_relative_strength_index
STOCHRSI <- stochastic_relative_strength_index

#' @usage NULL
#' @aliases stochastic_relative_strength_index
#'
#' @export
stochastic_relative_strength_index.default <- function(
	x,
	cols,
	n = 14,
	n_rsi = 14,
	fastk = 5,
	fastd = SMA(n = 3),
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
		x = cols,
		default = ~ high + low + close,
		data = x,
		...
	)

	## extract rownames
	## for later attachment
	x_names <- rownames(constructed_series)

	## calculate indicator and
	## return as data.frame
	x <- .Call(
		C_impl_ta_STOCHRSI,
		## splice:call:start
		relative_strength_index(
			constructed_series,
			n = n_rsi,
			na.bridge = na.bridge
		)[[
			1
		]][
			-seq_len(n_rsi)
		],
		as.integer(n),
		as.integer(fastk),
		fastd$n,
		fastd$maType,
		as.integer(n_rsi),
		## splice:call:end
		as.logical(na.bridge)
	)

	## readd rownames
	set_rownames(x, x_names)

	## return indicator
	x
}

#' @usage NULL
#' @aliases stochastic_relative_strength_index
#'
#' @export
stochastic_relative_strength_index.data.frame <- function(
	x,
	cols,
	n = 14,
	n_rsi = 14,
	fastk = 5,
	fastd = SMA(n = 3),
	na.bridge = FALSE,
	...
) {
	map_dfr(
		stochastic_relative_strength_index.default(
			x = x,
			cols = cols,
			n = n,
			n_rsi = n_rsi,
			fastk = fastk,
			fastd = fastd,
			na.bridge = na.bridge,
			...
		)
	)
}

#' @usage NULL
#' @aliases stochastic_relative_strength_index
#'
#' @export
stochastic_relative_strength_index.matrix <- function(
	x,
	cols,
	n = 14,
	n_rsi = 14,
	fastk = 5,
	fastd = SMA(n = 3),
	na.bridge = FALSE,
	...
) {
	stochastic_relative_strength_index.default(
		x = x,
		cols = cols,
		n = n,
		n_rsi = n_rsi,
		fastk = fastk,
		fastd = fastd,
		na.bridge = na.bridge,
		...
	)
}


#' @usage NULL
#' @aliases stochastic_relative_strength_index
#'
#' @export
stochastic_relative_strength_index.plotly <- function(
	x,
	cols,
	n = 14,
	n_rsi = 14,
	fastk = 5,
	fastd = SMA(n = 3),
	na.bridge = FALSE,
	## splice:optional-plotly:start
	lower_bound = 20,
	upper_bound = 80,
	## splice:optional-plotly:end
	title,
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
		default = ~ high + low + close,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- stochastic_relative_strength_index(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		n = n,
		n_rsi = n_rsi,
		fastk = fastk,
		fastd = fastd,
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
	name <- "Stochastic Relative Strength Index"

	decorators <- list(
		function(p) add_limit_ly(p, y_range = c(0, 100))
	)

	traces <- list(
		plotly_line(lower_bound),
		plotly_line(upper_bound),
		list(y = ~FastK, name = "Fast %K"),
		list(y = ~FastD, name = "Fast %D")
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
			title = if (missing(title)) {
				"Stochastic Relative Strength Index"
			} else {
				title
			}
		),
		data = constructed_indicator[, values_to_extract, drop = FALSE],
		values_to_extract = values_to_extract
	)

	state <- .chart_state()
	state$sub <- c(state$sub, list(plotly_object))

	plotly_object
}

#' @usage NULL
#' @aliases stochastic_relative_strength_index
#'
#' @export
stochastic_relative_strength_index.ggplot <- function(
	x,
	cols,
	n = 14,
	n_rsi = 14,
	fastk = 5,
	fastd = SMA(n = 3),
	na.bridge = FALSE,
	## splice:optional-ggplot:start
	## splice:optional-ggplot:end
	title,
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
		default = ~ high + low + close,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- stochastic_relative_strength_index(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		n = n,
		n_rsi = n_rsi,
		fastk = fastk,
		fastd = fastd,
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
		list(y = "FastK", name = "Fast %K"),
		list(y = "FastD", name = "Fast %D")
	)
	name <- "StochRSI"
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
			title = if (missing(title)) {
				"Stochastic Relative Strength Index"
			} else {
				title
			}
		),
		data = constructed_indicator[, values_to_extract, drop = FALSE],
		values_to_extract = values_to_extract,
		name = get0(x = "name", ifnotfound = NULL)
	)

	state <- .chart_state()
	state$sub <- c(state$sub, list(ggplot_object))

	ggplot_object
}
