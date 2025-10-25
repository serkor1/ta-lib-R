#' @export
#' @family Momentum Indicator
#'
#' @title Fast Stochastic
#' @templateVar .title Fast Stochastic
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun fast_stochastic
#'
## splice:documentation:start
#' @param fastk Time period for building the Fast-K line.
#' @param fastd Smoothing for making the Fast-D line.
## splice:documentation:end
#'
#' @template description
fast_stochastic <- function(
	x,
	cols,
	fastk = 5,
	fastd = SMA(n = 10),
	...
) {
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
	fastk = 5,
	fastd = SMA(n = 10),
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
		"impl_ta_STOCHF",
		## splice:call:start
		constructed_series[[1]],
		constructed_series[[2]],
		constructed_series[[3]],
		as.integer(fastk),
		as.integer(fastd$n),
		as.integer(fastd$maType)
		## splice:call:end
	)

	## readd rownames
	rownames(x) <- x_names

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
	fastk = 5,
	fastd = SMA(n = 10),
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases fast_stochastic
#'
#' @export
fast_stochastic.matrix <- function(
	x,
	cols,
	fastk = 5,
	fastd = SMA(n = 10),
	...
) {
	as.matrix(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases fast_stochastic
#'
#' @export
fast_stochastic.plotly <- function(
	x,
	cols,
	fastk = 5,
	fastd = SMA(n = 10),
	## splice:optional-plotly:start
	lower = 20,
	upper = 80,
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
	constructed_indicator <- fast_stochastic(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
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
		name = "Stochastic %K (Fast)",
		legendgroup = "stochastic_fast",
		showlegend = FALSE
	)

	plotly_object <- add_ribbons(
		plotly_object = plotly_object,
		data = constructed_indicator,
		x = ~idx,
		y = ~fastd,
		ymin = rep(lower, nrow(constructed_indicator)),
		ymax = rep(upper, nrow(constructed_indicator)),
		color = "lightgray",
		alpha = 0.7,
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
	## splice:plotly-assembly:end

	plotly_object
}
