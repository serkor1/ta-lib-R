#' @export
#' @family Momentum Indicator
#'
#' @title Fast Stochastic
#'
#' @templateVar .title Fast Stochastic
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun fast_stochastic
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

#' @usage NULL
#' @aliases fast_stochastic
#' @export
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

	slowk_ma <- map_maType_call(substitute(fast_d_MAtype))

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
	...
) {
	fast_d_MAtype <- substitute(fast_d_MAtype)
	slowk_ma <- map_maType_call(fast_d_MAtype)

	## construct HLC series
	HLC <- as.data.frame(series(
		x = x,
		formula = cols,
		default = ~ high + low + close,
		...
	))

	.indicator <- as.data.frame(
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

	.indicator$idx <- 1:nrow(.indicator)

	## Create
	output <- plotly::plot_ly(
		data = .indicator,
		x = ~idx,
		y = ~fastk,
		type = "scatter",
		mode = "lines",
		# line = list(color = ad_col),
		name = "Stochastic %K (Fast)",
		legendgroup = "stochastic_fast",
		showlegend = FALSE
	)

	output <- plotly::add_lines(
		output,
		x = ~idx,
		y = ~fastd,
		legendgroup = "stochastic_fast",
		name = "Stochastic %D (Fast)"
	)

	output <- add_title(
		x = output,
		text = "Fast Stochastic"
	)
	.plotting_environment$sub <- c(
		.plotting_environment$sub,
		list(output)
	)

	output
}
