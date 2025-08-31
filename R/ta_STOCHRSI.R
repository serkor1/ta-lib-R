#' @export
#' @family Momentum Indicator
#'
#' @title Stochastic Relative Strength Index
#'
#' @templateVar .title Stochastic Relative Strength Index
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun stochastic_relative_strength_index
#'
#' @template description
stochastic_relative_strength_index <- function(
	x,
	cols,
	n = 10,
	fast_k = 5,
	fast_d_MAtype = SMA(n = 10),
	...
) {
	UseMethod(
		"stochastic_relative_strength_index"
	)
}

#' @export
STOCHRSI <- stochastic_relative_strength_index

#' @export
stochastic_relative_strength_index.default <- function(
	x,
	cols,
	n = 10,
	fast_k = 5,
	fast_d_MAtype = SMA(n = 10),
	...
) {
	fast_d_MAtype <- map_maType_call(substitute(fast_d_MAtype))

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

	x <- series(
		x = cols,
		default = ~RSI,
		data = x,
		...
	)

	as.data.frame(
		.Call(
			"impl_ta_STOCHRSI",
			x[[1]],
			as.integer(n),
			as.integer(fast_k),
			fast_d_MAtype$n,
			fast_d_MAtype$maType
		)
	)
}


#' @usage NULL
#' @aliases stochastic_relative_strength_index
#' @export
stochastic_relative_strength_index.data.frame <- function(
	x,
	cols,
	n = 10,
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
	fast_k = 5,
	fast_d_MAtype = SMA(n = 10),
	...
) {
	## prepare series
	## from
	x <- as.data.frame(
		series(
			x = x,
			formula = cols,
			default = ~RSI,
			...
		)
	)

	## indicator
	.indicator <- as.data.frame(
		NextMethod()
	)
	.indicator$idx <- 1:nrow(.indicator)

	rsi_plot <- plotly::plot_ly(
		.indicator,
		x = ~idx,
		y = ~fastk,
		type = "scatter",
		mode = "lines",
		showlegend = FALSE
	)
	rsi_plot <- plotly::add_lines(
		.indicator,
		x = ~idx,
		y = ~fastk,
		showlegend = FALSE
	)

	.plotting_environment$sub <- c(
		.plotting_environment$sub,
		list(rsi_plot)
	)

	rsi_plot
}
