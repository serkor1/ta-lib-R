#' @export
#' @family Momentum Indicator
#'
#' @title Stochastic
#'
#' @templateVar .title Stochastic
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun stochastic
#'
#' @param fastk Time period for building the Fast-K line
#' @param slowk Smoothing for making the Slow-K line.
#' @param slowd Smoothing for making the Slow-D line
#'
#' @template description
stochastic <- function(
	x,
	cols,
	fastk = 5,
	slowk = SMA(n = 10),
	slowd = SMA(n = 8),
	...
) {
	UseMethod(
		"stochastic"
	)
}

#' @export
#'
#' @usage NULL
#'
#' @rdname stochastic
#' @aliases stochastic
STOCH <- stochastic

#' @usage NULL
#' @aliases stochastic
#' @export
stochastic.default <- function(
	x,
	cols,
	fastk = 5,
	slowk = SMA(n = 10),
	slowd = SMA(n = 8),
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

	# slowk <- map_maType_call(substitute(slowk))
	# slowd <- map_maType_call(substitute(slowd))

	as.data.frame(
		.Call(
			"impl_ta_STOCH",
			HLC[[1]],
			HLC[[2]],
			HLC[[3]],
			as.integer(fastk),
			as.integer(slowk$n),
			as.integer(slowk$maType),
			as.integer(slowd$n),
			as.integer(slowd$maType)
		)
	)
}

#' @usage NULL
#' @aliases stochastic
#' @export
stochastic.data.frame <- function(
	x,
	cols,
	fastk = 5,
	slowk = SMA(n = 10),
	slowd = SMA(n = 8),
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases stochastic
#' @export
stochastic.matrix <- function(
	x,
	cols,
	fastk = 5,
	slowk = SMA(n = 10),
	slowd = SMA(n = 8),
	...
) {
	as.matrix(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases stochastic
#' @export
stochastic.plotly <- function(
	x,
	cols,
	fastk = 5,
	slowk = SMA(n = 10),
	slowd = SMA(n = 8),
	lower = 20,
	upper = 80,
	color = "lightgray",
	alpha = 0.7,
	...
) {
	## construct HLC series
	## for stochastic
	HLC <- as.data.frame(
		series(
			x = x,
			formula = cols,
			default = ~ high + low + close,
			...
		)
	)

	## calculate stochastic
	## and return as data.frame
	.indicator <- stochastic.default(
		x = HLC,
		cols = rebuild_formula(
			x = names(HLC)
		),
		fastk = fastk,
		slowk = slowk,
		slowd = slowd
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
		y = ~slowk,
		type = "scatter",
		mode = "lines",
		name = "Stocastic %K",
		legendgroup = "STOCH",
		showlegend = TRUE
	)

	plotly_object <- add_ribbons(
		plotly_object = plotly_object,
		data = .indicator,
		x = ~idx,
		y = ~slowd,
		ymin = rep(lower, nrow(.indicator)),
		ymax = rep(upper, nrow(.indicator)),
		color = color,
		alpha = alpha,
		showlegend = TRUE,
		dash = c("solid", "dot", "dot"),
		name = c("Stochastic %D", "Lower", "Upper"),
		legendgroup = "STOCH"
	)

	if (main_chart_exists()) {
		plotly_object <- add_title(
			x = plotly_object,
			text = "Stochastic"
		)
	}

	.plotting_environment$sub <- c(
		.plotting_environment$sub,
		list(plotly_object)
	)

	plotly_object
}
