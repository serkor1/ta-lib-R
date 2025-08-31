#' @export
#' @family Volume Indicator
#'
#' @title Chaikin A/D Oscillator
#'
#' @templateVar .title Chaikin A/D Oscillator
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun chaikin_AD_oscillator
#'
#' @template description
chaikin_AD_oscillator <- function(x, cols, fast = 3, slow = 10, ...) {
	UseMethod(
		"chaikin_AD_oscillator"
	)
}

#' @usage NULL
#' @aliases chaikin_AD_oscillator
#' @export
ADOSC <- chaikin_AD_oscillator

#' @export
chaikin_AD_oscillator.default <- function(x, cols, fast = 3, slow = 10, ...) {
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
	...
) {
	## prepare series
	HLCV <- series(
		x = x,
		formula = cols,
		default = ~ high + low + close + volume,
		...
	)

	.indicator <- data.frame(
		AD_line = .Call(
			"impl_ta_ADOSC",
			HLCV[[1]],
			HLCV[[2]],
			HLCV[[3]],
			HLCV[[4]],
			as.integer(fast),
			as.integer(slow)
		)
	)

	.indicator$idx <- 1:nrow(.indicator)
	ad_col <- "#1f77b4"

	ad_plot <- plotly::plot_ly(
		data = .indicator,
		x = ~idx,
		y = ~AD_line,
		type = "scatter",
		mode = "lines",
		line = list(color = ad_col),
		name = "AD",
		legendgroup = "ChaikinOscillator",
		showlegend = FALSE
	)

	# dashed y = 0 line in the same color
	ad_plot <- plotly::add_lines(
		p = ad_plot,
		x = .indicator$idx,
		y = 0,
		line = list(color = ad_col, dash = "dash"),
		showlegend = FALSE,
		hoverinfo = "skip",
		legendgroup = "ChaikinOscillator",
		name = "Zero"
	)

	ad_plot <- add_title(
		x = ad_plot,
		text = "Chaikin A/D Oscillator"
	)
	.plotting_environment$sub <- c(
		.plotting_environment$sub,
		list(ad_plot)
	)

	ad_plot
}
