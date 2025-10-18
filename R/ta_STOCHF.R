#' @export
#' @family Momentum Indicator
#'
#' @title Fast Stochastic
#'
#' @templateVar .title Fast Stochastic
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun fast_stochastic
#'
#' @param fast_k Time period for building the Fast-K line.
#' @param fast_d_MAtype Smoothing for making the Fast-D line.
#'
#' @template description
fast_stochastic <- function(
	x,
	cols,
	fast_k = 5,
	fast_d_MAtype = SMA(n = 10),
	...
) {
	UseMethod(
		"fast_stochastic"
	)
}

#' @export
#'
#' @usage NULL
#'
#' @rdname fast_stochastic
#' @aliases fast_stochastic
STOCHF <- fast_stochastic

#' @usage NULL
#' @aliases fast_stochastic
#' @export
fast_stochastic.default <- function(
	x,
	cols,
	fast_k = 5,
	fast_d_MAtype = SMA(n = 10),
	...
) {
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
			length(all.vars(cols)) == 3,
			paste0(
				"'cols' has to be length 3. ",
				"Got length ",
				length(all.vars(cols))
			)
		)
	}

	## construct HLC series
	HLC <- series(
		x = cols,
		default = ~ high + low + close,
		data = x,
		...
	)

	slowk_ma <- fast_d_MAtype

	as.data.frame(
		.Call(
			"impl_ta_STOCHF",
			HLC[[1]],
			HLC[[2]],
			HLC[[3]],
			as.integer(fast_k),
			as.integer(slowk_ma$n),
			as.integer(slowk_ma$maType)
		)
	)
}


#' @usage NULL
#' @aliases fast_stochastic
#' @export
fast_stochastic.data.frame <- function(
	x,
	cols,
	fast_k = 5,
	fast_d_MAtype = SMA(n = 10),
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases fast_stochastic
#' @export
fast_stochastic.matrix <- function(
	x,
	cols,
	fast_k = 5,
	fast_d_MAtype = SMA(n = 10),
	...
) {
	as.matrix(
		NextMethod()
	)
}


#' @usage NULL
#' @aliases fast_stochastic
#' @export
fast_stochastic.plotly <- function(
	x,
	cols,
	fast_k = 5,
	fast_d_MAtype = SMA(n = 10),
	lower = 20,
	upper = 80,
	color = "lightgray",
	alpha = 0.7,
	...
) {
	## input arguments
	slowk_ma <- fast_d_MAtype

	## prepare HLC
	## series for stochastic
	## relative strength index
	HLC <- as.data.frame(series(
		x = x,
		formula = cols,
		default = ~ high + low + close,
		...
	))

	## calculate indicator
	## and return as data.frame
	.indicator <- fast_stochastic.default(
		x = HLC,
		cols = rebuild_formula(
			names(HLC)
		),
		fast_k = fast_k,
		fast_d_MAtype = fast_d_MAtype
	)

	## add x-axis conditional on whether
	## the data have been subsetted or not
	.indicator$idx <- add_idx(
		HLC
	)

	## generate plotly object
	## of the indicator
	plotly_object <- subchart(
		data = .indicator,
		y = ~fastk,
		type = "scatter",
		mode = "lines",
		name = "Stochastic %K (Fast)",
		legendgroup = "stochastic_fast",
		showlegend = FALSE
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
		dash = c("solid", "dot", "dot"),
		legendgroup = "stochastic_fast",
		name = c("Stochastic %D (Fast)", "Lower", "Upper"),
		showlegend = TRUE
	)

	if (main_chart_exists()) {
		plotly_object <- add_title(
			x = plotly_object,
			text = "Fast Stochastic"
		)
	}

	.plotting_environment$sub <- c(
		.plotting_environment$sub,
		list(plotly_object)
	)

	plotly_object
}
