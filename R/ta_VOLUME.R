#' @export
#' @family Volume Indicator
#'
#' @title Trading Volume
#'
#' @templateVar .title Trading Volume
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun trading_volume
#'
#' @param ma An optional list of moving average specifications.
#'
#' @template description
trading_volume <- function(
	x,
	cols,
	ma,
	...
) {
	UseMethod(
		"trading_volume"
	)
}

#' @export
#'
#' @usage NULL
#'
#' @rdname trading_volume
#' @aliases trading_volume
volume <- trading_volume

#' @rdname trading_volume
#' @usage NULL
#' @export
trading_volume.default <- function(
	x,
	cols,
	ma,
	...
) {
	## default behaviour is to
	## check if its a numeric vector
	##
	## No coercing here as it might
	## lead to overflow
	x <- series(
		x = cols,
		default = ~volume,
		data = x,
		...
	)

	## 0) validate input
	##    and stop the script
	##    if conditions are not
	##    met
	if (!missing(ma)) {
		xx <- vapply(
			ma,
			FUN = function(ma_) {
				.Call(
					"impl_ta_MA",
					x[[1]],
					ma_$n,
					ma_$maType
				)
			},
			FUN.VALUE = double(nrow(x)),
			USE.NAMES = TRUE
		)

		x <- as.data.frame(
			cbind(x, xx)
		)
	}

	x
}

#' @rdname trading_volume
#' @usage NULL
#' @export
trading_volume.numeric <- function(
	x,
	cols,
	ma,
	...
) {
	if (!missing(cols)) {
		warning(
			"'cols' have been passed but is unused in for vectors"
		)
	}

	NextMethod()
}


#' @rdname trading_volume
#' @usage NULL
#' @export
trading_volume.data.frame <- function(
	x,
	cols,
	ma,
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @rdname trading_volume
#' @usage NULL
#' @export
trading_volume.matrix <- function(
	x,
	cols,
	ma,
	...
) {
	as.matrix(
		NextMethod()
	)
}

#' @rdname trading_volume
#' @usage NULL
#' @export
trading_volume.plotly <- function(
	x,
	cols,
	ma,
	...
) {
	## prepare univariate
	## series for trading_volume
	x <- as.data.frame(
		series(
			x = x,
			formula = cols,
			default = ~ open + close + volume,
			...
		)
	)

	## calculator indicator
	## and return as data.frame
	.indicator <- trading_volume.default(
		x = x,
		cols = rebuild_formula(
			x = names(x)[names(x) %in% "volume"]
		),
		ma = ma
	)

	## add x-axis conditional on whether
	## the data have been subsetted or not
	.indicator$idx <- add_idx(
		x
	)

	.indicator$direction <- x$open >= x$close

	## construct chart
	chart_theme <- .chart_theme()

	plotly_object <- subchart(
		data = .indicator,
		y = ~volume,
		color = ~direction,
		colors = c(
			chart_theme$bull_color,
			chart_theme$bear_color
		),
		type = 'bar',
		showlegend = FALSE
	)

	## only chart the smoothing lines
	## if passed
	if (!missing(ma)) {
		for (i in 2:(ncol(.indicator) - 2)) {
			plotly_object <- plotly::add_trace(
				plotly_object,
				data = .indicator,
				x = ~idx,
				y = .indicator[[i]],
				type = "scatter",
				mode = "lines",
				inherit = FALSE
			)
		}
	}

	.plotting_environment$sub <- c(
		.plotting_environment$sub,
		list(plotly_object)
	)

	plotly_object
}
