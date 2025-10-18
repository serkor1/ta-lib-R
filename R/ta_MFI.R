#' @export
#' @family Momentum Indicator
#'
#' @title Money Flow Index
#'
#' @templateVar .title Money Flow Index
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun money_flow_index
#'
#' @template description
money_flow_index <- function(
	x,
	cols,
	n = 10,
	...
) {
	UseMethod("money_flow_index")
}

#' @export
#'
#' @usage NULL
#'
#' @rdname money_flow_index
#' @aliases money_flow_index
MFI <- money_flow_index

#' @usage NULL
#' @aliases money_flow_index
#' @export
money_flow_index.default <- function(
	x,
	cols,
	n = 10,
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
			length(all.vars(cols)) == 4,
			paste0(
				"'cols' has to be length 4. ",
				"Got length ",
				length(all.vars(cols))
			)
		)
	}

	HLCV <- series(
		x = cols,
		default = ~ high + low + close + volume,
		data = x,
		...
	)

	assert(n >= 2)

	## 1) pass `x` assuming that it
	##    follows OHLC-V structure
	output <- as.data.frame(
		.Call(
			"impl_ta_MFI",
			HLCV[[1]],
			HLCV[[2]],
			HLCV[[3]],
			HLCV[[4]],
			as.integer(n)
		)
	)

	colnames(output) <- "MFI"

	output
}

#' @usage NULL
#' @aliases money_flow_index
#' @export
money_flow_index.data.frame <- function(
	x,
	cols,
	n = 10,
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases money_flow_index
#' @export
money_flow_index.matrix <- function(
	x,
	cols,
	n = 10,
	...
) {
	as.matrix(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases money_flow_index
#' @export
money_flow_index.plotly <- function(
	x,
	cols,
	n = 10,
	lower = -20,
	upper = 80,
	...
) {
	## prepare series
	## from
	HLCV <- series(
		x = x,
		formula = cols,
		default = ~ high + low + close + volume,
		...
	)

	## calculate money flow index
	## and return as
	## data.frame
	.indicator <- money_flow_index.default(
		x = HLCV,
		cols = rebuild_formula(
			names(HLCV)
		),
		n = n
	)

	## add x-axis conditional on whether
	## the data have been subsetted or not
	.indicator$idx <- add_idx(
		HLCV
	)

	## construct plot with ribbons
	## on upper and lower limits
	plotly_object <- subchart(
		data = .indicator,
		y = ~MFI,
		type = "scatter",
		mode = "lines",
		showlegend = FALSE
	)

	plotly_object <- plotly::add_ribbons(
		plotly_object,
		x = ~idx,
		ymin = rep(lower, nrow(.indicator)),
		ymax = rep(upper, nrow(.indicator)),
		line = list(width = 0),
		fillcolor = plotly::toRGB(
			x = "lightgray",
			alpha = 0.2
		)
	)

	if (main_chart_exists()) {
		plotly_object <- add_title(
			x = plotly_object,
			text = sprintf(
				"Money Flow Index (%d)",
				n
			)
		)
	}

	.plotting_environment$sub <- c(
		.plotting_environment$sub,
		list(plotly_object)
	)

	plotly_object
}
