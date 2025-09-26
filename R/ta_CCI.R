#' @export
#' @family Momentum Indicator
#'
#' @title Commodity Channel Index
#'
#' @templateVar .title Commodity Channel Index
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun commodity_channel_index
#'
#' @template description
commodity_channel_index <- function(
	x,
	cols,
	n = 10,
	...
) {
	UseMethod(
		generic = "commodity_channel_index"
	)
}

#' @export
#'
#' @usage NULL
#'
#' @rdname commodity_channel_index
#' @aliases commodity_channel_index
CCI <- commodity_channel_index

#' @usage NULL
#' @aliases commodity_channel_index
#' @export
commodity_channel_index.default <- function(
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
			length(all.vars(cols)) == 3,
			paste0(
				"'cols' has to be length 3. ",
				"Got length ",
				length(all.vars(cols))
			)
		)
	}

	## default behaviour is to
	## coerce to a `matrix` check that
	## it is double and then pass to
	## C-side.
	HLC <- series(
		x = cols,
		default = ~ high + low + close,
		data = x,
		...
	)

	## 1) pass `x` assuming that it
	##    follows OHLC-V structure
	x <- as.data.frame(
		.Call(
			"impl_ta_CCI",
			HLC[[1]],
			HLC[[2]],
			HLC[[3]],
			as.integer(n)
		)
	)

	colnames(x) <- "CCI"

	return(x)
}

#' @usage NULL
#' @aliases commodity_channel_index
#' @export
commodity_channel_index.data.frame <- function(
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
#' @aliases commodity_channel_index
#' @export
commodity_channel_index.matrix <- function(
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
#' @aliases commodity_channel_index
#' @export
commodity_channel_index.plotly <- function(
	x,
	cols,
	n = 10,
	...
) {
	## prepare series
	## from {plotly}-object
	HLC <- as.data.frame(
		series(
			x = x,
			formula = cols,
			default = ~ high + low + close,
			...
		)
	)

	## construct indicator
	.indicator <- as.data.frame(
		.Call(
			"impl_ta_CCI",
			HLC[[1]],
			HLC[[2]],
			HLC[[3]],
			as.integer(n)
		)
	)

	colnames(.indicator) <- "CCI"
	.indicator$idx <- 1:nrow(.indicator)

	## construct plot with ribbons
	## on upper and lower limits
	output <- plotly::plot_ly(
		data = .indicator,
		x = ~idx,
		y = ~CCI,
		type = "scatter",
		mode = "lines",
		showlegend = FALSE
	)

	output <- plotly::add_ribbons(
		output,
		x = ~idx,
		ymin = rep(-100, nrow(.indicator)),
		ymax = rep(100, nrow(.indicator)),
		line = list(width = 0),
		fillcolor = plotly::toRGB(
			x = "lightgray",
			alpha = 0.2
		)
	)

	output <- add_title(
		x = output,
		text = sprintf(
			"Commodity Channel Index (%d)",
			n
		)
	)

	.plotting_environment$sub <- c(
		.plotting_environment$sub,
		list(output)
	)

	output
}
