#' @export
#' @family Momentum Indicator
#'
#' @title Stochastic
#' @templateVar .title Stochastic
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun stochastic
#'
## splice:documentation:start
## splice:documentation:end
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
	UseMethod("stochastic")
}

#' @export
#' @usage NULL
#' @rdname stochastic
#'
#' @aliases stochastic
STOCH <- stochastic

#' @usage NULL
#' @aliases stochastic
#'
#' @export
stochastic.default <- function(
	x,
	cols,
	fastk = 5,
	slowk = SMA(n = 10),
	slowd = SMA(n = 8),
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
		"impl_ta_STOCH",
		## splice:call:start
		constructed_series[[1]],
		constructed_series[[2]],
		constructed_series[[3]],
		as.integer(fastk),
		as.integer(slowk$n),
		as.integer(slowk$maType),
		as.integer(slowd$n),
		as.integer(slowd$maType)
		## splice:call:end
	)

	## readd rownames
	rownames(x) <- x_names

	## return indicator
	x
}

#' @usage NULL
#' @aliases stochastic
#'
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
#'
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
#'
#' @export
stochastic.plotly <- function(
	x,
	cols,
	fastk = 5,
	slowk = SMA(n = 10),
	slowd = SMA(n = 8),
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
	constructed_indicator <- stochastic(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		fastk = fastk,
		slowk = slowk,
		slowd = slowd
	)

	## add conditional idx
	constructed_indicator[["idx"]] <- add_idx(
		constructed_series
	)

	## construct {plotly}-object
	## splice:plotly-assembly:start
	plotly_object <- subchart(
		data = constructed_indicator,
		y = ~slowk,
		type = "scatter",
		mode = "lines",
		name = "Stocastic %K",
		legendgroup = "STOCH",
		showlegend = TRUE
	)

	plotly_object <- add_ribbons(
		plotly_object = plotly_object,
		data = constructed_indicator,
		x = ~idx,
		y = ~slowd,
		ymin = rep(20, nrow(constructed_indicator)),
		ymax = rep(80, nrow(constructed_indicator)),
		color = "lightgray",
		alpha = 0.7,
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
	## splice:plotly-assembly:end

	plotly_object
}
