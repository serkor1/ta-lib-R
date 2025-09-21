#' @export
#' @family Momentum Indicator
#'
#' @title Aroon Oscillator
#' @templateVar .title Aroon Oscillator
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun aroon_oscillator
#'
#' @returns
#' A [data.frame]- or [matrix]-object:
#'
#' \describe{
#'  \item{aroon_oscillator <[double]>}{}
#' }
#'
#' @template description
aroon_oscillator <- function(
	x,
	cols,
	n = 10,
	...
) {
	UseMethod(
		generic = "aroon_oscillator"
	)
}

#' @usage NULL
#' @aliases aroon_oscillator
#' @export
AROONOSC <- aroon_oscillator

#' @export
aroon_oscillator.default <- function(
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
			length(all.vars(cols)) == 2,
			paste0(
				"'cols' has to be length 2. ",
				"Got length ",
				length(all.vars(cols))
			)
		)
	}

	HL <- series(
		x = cols,
		default = ~ high + low,
		data = x,
		...
	)

	data.frame(
		aroon_oscillator = .Call(
			"impl_ta_AROONOSC",
			HL[[1]],
			HL[[2]],
			as.integer(n)
		)
	)
}


#' @usage NULL
#' @aliases aroon_oscillator
#' @export
aroon_oscillator.data.frame <- function(
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
#' @aliases aroon_oscillator
#' @export
aroon_oscillator.matrix <- function(
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
#' @aliases aroon_oscillator
#' @export
aroon_oscillator.plotly <- function(
	x,
	cols,
	n = 10,
	...
) {
	HL <- series(
		x = x,
		formula = cols,
		default = ~ high + low,
		...
	)

	.indicator <- data.frame(
		aroon_oscillator = .Call(
			"impl_ta_AROONOSC",
			HL[[1]],
			HL[[2]],
			as.integer(n)
		)
	)

	.indicator$idx <- 1:nrow(.indicator)

	ad_plot <- plotly::plot_ly(
		data = .indicator,
		x = ~idx,
		y = ~aroon_oscillator,
		type = "scatter",
		mode = "lines",
		# line = list(color = ad_col),
		name = "AD",
		legendgroup = "Aroon",
		showlegend = FALSE
	)

	ad_plot <- add_title(
		x = ad_plot,
		text = "Aroon Oscillator"
	)
	.plotting_environment$sub <- c(
		.plotting_environment$sub,
		list(ad_plot)
	)

	ad_plot
}
