#' @export
#' @family Momentum Indicator
#'
#' @title Stochastic Relative Strength Index
#' @templateVar .title Stochastic Relative Strength Index
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun stochastic_relative_strength_index
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
stochastic_relative_strength_index <- function(
	x,
	cols,
	n = 10,
	n_rsi = 10,
	fastk = 5,
	fastd = SMA(n = 10),
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
	n = 10,
	n_rsi = 10,
	fastk = 5,
	fastd = SMA(n = 10),
	...
) {
	## validate 'cols'-argument
	## if explicitly passed
	if (!missing(cols)) {
		assert_formula(cols)
	}

	## extract rownames
	## for later attachment
	x_names <- rownames(x)

	## construct series
	## from input
	constructed_series <- series(
		x = cols,
		default = ~ high + low + close,
		data = x,
		...
	)

	## calculate indicator and
	## return as data.frame
	x <- .Call(
		"impl_ta_STOCHRSI",
		## splice:call:start
		relative_strength_index(constructed_series, n = n_rsi)[[1]][
			-seq_len(n_rsi)
		],
		as.integer(n),
		as.integer(fastk),
		fastd$n,
		fastd$maType,
		as.integer(n_rsi)
		## splice:call:end
	)

	## readd rownames
	rownames(x) <- x_names

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
	n = 10,
	n_rsi = 10,
	fastk = 5,
	fastd = SMA(n = 10),
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases stochastic_relative_strength_index
#'
#' @export
stochastic_relative_strength_index.matrix <- function(
	x,
	cols,
	n = 10,
	n_rsi = 10,
	fastk = 5,
	fastd = SMA(n = 10),
	...
) {
	as.matrix(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases stochastic_relative_strength_index
#'
#' @export
stochastic_relative_strength_index.plotly <- function(
	x,
	cols,
	n = 10,
	n_rsi = 10,
	fastk = 5,
	fastd = SMA(n = 10),
	## splice:optional-plotly:start
	## splice:optional-plotly:end
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
		fastd = fastd
	)

	## add conditional idx
	constructed_indicator[["idx"]] <- add_idx(
		constructed_series
	)

	## construct {plotly}-object
	## splice:plotly-assembly:start
	plotly_object <- subchart(
		data = constructed_indicator,
		y = ~fastk,
		type = "scatter",
		mode = "lines",
		name = "StochRSI %K",
		legendgroup = "stochrsi",
		showlegend = TRUE
	)

	plotly_object <- add_ribbons(
		plotly_object = plotly_object,
		data = constructed_indicator,
		x = ~idx,
		y = ~fastd,
		ymin = rep(20, nrow(constructed_indicator)),
		ymax = rep(80, nrow(constructed_indicator)),
		color = "lightgray",
		alpha = 0.2,
		showlegend = TRUE,
		dash = c("solid", "dot", "dot"),
		name = c("StochRSI %D", "Lower", "Upper"),
		legendgroup = "stochrsi"
	)

	if (main_chart_exists()) {
		plotly_object <- add_title(
			x = plotly_object,
			text = "StochRSI"
		)
	}

	.plotting_environment$sub <- c(
		.plotting_environment$sub,
		list(plotly_object)
	)
	## splice:plotly-assembly:end

	plotly_object
}
