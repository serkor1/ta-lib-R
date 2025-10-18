#' @export
#' @family Volume Indicator
#'
#' @title Chaikin A/D Oscillator
#'
#' @templateVar .title Chaikin A/D Oscillator
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun chaikin_AD_oscillator
#'
#' @param fast An <[integer]> of [length] 1. The window size passed into the fast moving average (MA).
#' @param slow An <[integer]> of [length] 1. The window size passed into the slow moving average (MA).
#'
#' @returns
#' A [data.frame]- or [matrix]-object:
#'
#' \describe{
#'  \item{AD_oscillator <[double]>}{Chaikin A/D Oscillator}
#' }
#'
#' @template description
chaikin_AD_oscillator <- function(
	x,
	cols,
	fast = 3,
	slow = 10,
	...
) {
	UseMethod(
		"chaikin_AD_oscillator"
	)
}

#' @export
#'
#' @usage NULL
#'
#' @rdname chaikin_AD_oscillator
#' @aliases chaikin_AD_oscillator
ADOSC <- chaikin_AD_oscillator

#' @export
chaikin_AD_oscillator.default <- function(
	x,
	cols,
	fast = 3,
	slow = 10,
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

	data.frame(
		AD_oscillator = .Call(
			"impl_ta_ADOSC",
			HLCV[[1]],
			HLCV[[2]],
			HLCV[[3]],
			HLCV[[4]],
			as.integer(fast),
			as.integer(slow)
		)
	)
}


#' @usage NULL
#' @aliases chaikin_AD_oscillator
#' @export
chaikin_AD_oscillator.data.frame <- function(
	x,
	cols,
	fast = 3,
	slow = 10,
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases chaikin_AD_oscillator
#' @export
chaikin_AD_oscillator.matrix <- function(
	x,
	cols,
	fast = 3,
	slow = 10,
	...
) {
	as.matrix(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases chaikin_AD_oscillator
#' @export
chaikin_AD_oscillator.plotly <- function(
	x,
	cols,
	fast = 3,
	slow = 10,
	color = "steelblue",
	...
) {
	## prepare HLCV series
	## for the chaikin A/D line
	HLCV <- series(
		x = x,
		formula = cols,
		default = ~ high + low + close + volume,
		...
	)

	## calculate indicator
	## and return as data.frame
	.indicator <- chaikin_AD_oscillator.default(
		x = HLCV,
		cols = rebuild_formula(
			names(HLCV)
		),
		fast = fast,
		slow = slow
	)

	## add x-axis conditional on whether
	## the data have been subsetted or not
	.indicator$idx <- add_idx(
		HLCV
	)

	plotly_object <- subchart(
		data = .indicator,
		y = ~AD_oscillator,
		type = "scatter",
		mode = "lines",
		line = list(
			color = plotly::toRGB(
				x = color,
				alpha = 1
			)
		),
		name = "AD",
		legendgroup = "ChaikinOscillator",
		showlegend = FALSE
	)

	plotly_object <- plotly::add_lines(
		p = plotly_object,
		x = .indicator$idx,
		y = 0,
		line = list(
			color = plotly::toRGB(
				x = color,
				alpha = 1
			),
			dash = "dot"
		),
		showlegend = FALSE,
		hoverinfo = "skip",
		legendgroup = "ChaikinOscillator",
		name = "Zero"
	)

	if (main_chart_exists()) {
		plotly_object <- add_title(
			x = plotly_object,
			text = "Chaikin A/D Oscillator"
		)
	}

	.plotting_environment$sub <- c(
		.plotting_environment$sub,
		list(plotly_object)
	)

	plotly_object
}
