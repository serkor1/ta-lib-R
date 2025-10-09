#' @export
#' @family Momentum Indicator
#'
#' @title Stochastic Relative Strength Index
#'
#' @templateVar .title Stochastic Relative Strength Index
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun stochastic_relative_strength_index
#'
#' @param fast_k Time period for building the Fast-K line.
#' @param fast_d_MAtype Smoothing for making the Fast-D line.
#' @param n_rsi Time period for [relative_strength_index]
#'
#' @template description
stochastic_relative_strength_index <- function(
	x,
	cols,
	n = 10,
	n_rsi = 10,
	fast_k = 5,
	fast_d_MAtype = SMA(n = 10),
	...
) {
	UseMethod(
		"stochastic_relative_strength_index"
	)
}

#' @export
#'
#' @usage NULL
#'
#' @rdname stochastic_relative_strength_index
#' @aliases stochastic_relative_strength_index
STOCHRSI <- stochastic_relative_strength_index

#' @usage NULL
#' @aliases stochastic_relative_strength_index
#' @export
stochastic_relative_strength_index.default <- function(
	x,
	cols,
	n = 10,
	n_rsi = 10,
	fast_k = 5,
	fast_d_MAtype = SMA(n = 10),
	na.rm = TRUE,
	...
) {
	## calculate the rows of
	## 'x' as the StochRSI is a combination
	## of two indicators the the lengths
	## will be clipped - all functions must
	## have nrow(in) == nrow(out)
	x_rows <- nrow(x)

	## check input
	## cols if passed
	if (!missing(cols)) {
		assert(
			is.formula(cols),
			paste0(
				"'cols' has to be <",
				class(~s),
				">. ",
				"Got <",
				class(cols),
				">."
			)
		)
		assert(
			length(all.vars(cols)) == 1,
			paste0(
				"'cols' has to be length 1. ",
				"Got length ",
				length(all.vars(cols))
			)
		)
	}

	## calculate RSI
	x <- relative_strength_index.default(
		x = x,
		cols = cols,
		n = n_rsi,
		...
	)

	x <- as.data.frame(
		.Call(
			"impl_ta_STOCHRSI",
			x[[1]][!is.na(x[[1]])],
			as.integer(n),
			as.integer(fast_k),
			fast_d_MAtype$n,
			fast_d_MAtype$maType
		)
	)

	## append na values
	## if there is a mismatch
	## between input rows and
	## output rows
	if (nrow(x) != x_rows) {
		x <- na_pad(
			x = x,
			n = x_rows - nrow(x)
		)
	}

	return(
		x
	)
}

#' @usage NULL
#' @aliases stochastic_relative_strength_index
#' @export
stochastic_relative_strength_index.data.frame <- function(
	x,
	cols,
	n = 10,
	n_rsi = 10,
	fast_k = 5,
	fast_d_MAtype = SMA(n = 10),
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases stochastic_relative_strength_index
#' @export
stochastic_relative_strength_index.matrix <- function(
	x,
	cols,
	n = 10,
	n_rsi = 10,
	fast_k = 5,
	fast_d_MAtype = SMA(n = 10),
	...
) {
	as.matrix(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases stochastic_relative_strength_index
#' @export
stochastic_relative_strength_index.plotly <- function(
	x,
	cols,
	n = 10,
	n_rsi = 10,
	fast_k = 5,
	fast_d_MAtype = SMA(n = 10),
	lower = 20,
	upper = 80,
	color = "lightgray",
	alpha = 0.7,
	...
) {
	## input arguments
	fast_d_MAtype <- fast_d_MAtype

	## prepare univariate
	## series for stochastic
	## relative strength index
	x <- as.data.frame(
		series(
			x = x,
			formula = cols,
			default = ~open,
			...
		)
	)

	## calculate indicator
	## and return as data.frame
	.indicator <- stochastic_relative_strength_index.default(
		x = x,
		cols = rebuild_formula(
			names(x)
		),
		n = n,
		n_rsi = n_rsi,
		fast_k = fast_k,
		fast_d_MAtype = fast_d_MAtype
	)

	## add x-axis conditional on whether
	## the data have been subsetted or not
	.indicator$idx <- add_idx(
		x
	)

	## generate plotly object
	## of the indicator
	plotly_object <- subchart(
		data = .indicator,
		y = ~fastk,
		type = "scatter",
		mode = "lines",
		name = "StochRSI %K",
		legendgroup = "stochrsi",
		showlegend = TRUE
	)

	plotly_object <- add_ribbons(
		plotly_object = plotly_object,
		data = .indicator,
		x = ~idx,
		y = ~fastd,
		ymin = rep(lower, nrow(.indicator)),
		ymax = rep(upper, nrow(.indicator)),
		color = color,
		alpha = alpha,
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

	plotly_object
}
