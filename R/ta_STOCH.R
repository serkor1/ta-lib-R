#' @export
#' @family Momentum Indicator
#'
#' @title Stochastic
#'
#' @templateVar .title Stochastic
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun stochastic
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

#' @usage NULL
#' @aliases stochastic
#' @export
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

	slowk_ma <- map_maType_call(substitute(slowk))
	slowd_ma <- map_maType_call(substitute(slowd))

	as.data.frame(
		.Call(
			"impl_ta_STOCH",
			HLC[[1]],
			HLC[[2]],
			HLC[[3]],
			as.integer(fastk),
			as.integer(slowk_ma$n),
			as.integer(slowk_ma$maType),
			as.integer(slowd_ma$n),
			as.integer(slowd_ma$maType)
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
	...
) {
	# slowk_ma <- map_maType_call(substitute(slowk))
	# slowd_ma <- map_maType_call(substitute(slowd))
	slowk <- substitute(slowk)
	slowd <- substitute(slowd)
	slowk_ma <- map_maType_call(slowk)
	slowd_ma <- map_maType_call(slowd)
	## construct HLC series
	HLC <- as.data.frame(
		series(
			x = x,
			formula = cols,
			default = ~ high + low + close,
			...
		)
	)

	.indicator <- as.data.frame(
		.Call(
			"impl_ta_STOCH",
			HLC[[1]],
			HLC[[2]],
			HLC[[3]],
			as.integer(fastk),
			as.integer(slowk_ma$n),
			as.integer(slowk_ma$maType),
			as.integer(slowd_ma$n),
			as.integer(slowd_ma$maType)
		)
	)

	.indicator$idx <- 1:nrow(.indicator)

	## Create
	output <- plotly::plot_ly(
		data = .indicator,
		x = ~idx,
		y = ~slowk,
		type = "scatter",
		mode = "lines",
		# line = list(color = ad_col),
		name = "Stochastic %K",
		legendgroup = "stochastic",
		showlegend = TRUE
	)

	output <- plotly::add_lines(
		output,
		x = ~idx,
		y = ~slowd,
		name = "Stochastic %D",
		legendgroup = "stochastic",
		showlegend = TRUE
	)

	output <- add_title(
		x = output,
		text = "Stochastic"
	)
	.plotting_environment$sub <- c(
		.plotting_environment$sub,
		list(output)
	)

	output
}
