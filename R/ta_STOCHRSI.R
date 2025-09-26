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

#' @usage NULL
#' @aliases stochastic_relative_strength_index
#' @export
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
	...
) {
	## input arguments
	fast_d_MAtype <- fast_d_MAtype

	## prepare series
	## from
	x <- as.data.frame(
		series(
			x = x,
			formula = cols,
			default = ~open,
			...
		)
	)

	## indicator
	.indicator <- stochastic_relative_strength_index.default(
		x = x,
		cols = cols,
		n = n,
		n_rsi = n_rsi,
		fast_k = fast_k,
		fast_d_MAtype = fast_d_MAtype
	)

	.indicator$idx <- 1:nrow(.indicator)

	# plot
	output <- plotly::plot_ly(
		data = .indicator,
		x = ~idx,
		y = ~fastk,
		type = "scatter",
		mode = "lines",
		name = "StochRSI %K",
		legendgroup = "stochrsi",
		showlegend = TRUE
	)

	output <- plotly::add_lines(
		output,
		x = ~idx,
		y = ~fastd,
		name = "StochRSI %D",
		legendgroup = "stochrsi",
		showlegend = TRUE
	)

	output <- add_title(
		x = output,
		text = "StochRSI"
	)

	.plotting_environment$sub <- c(
		.plotting_environment$sub,
		list(output)
	)

	output
}
