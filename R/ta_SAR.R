#' @export
#' @family Overlap Study
#'
#' @title Parabolic Stop and Reverse (SAR)
#'
#' @templateVar .title Parabolic Stop and Reverse (SAR)
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun parabolic_sar
#'
#' @param acceleration Acceleration Factor used up to the Maximum value
#' @param maximum Acceleration Factor Maximum value
#'
#' @returns
#' A [data.frame]- or [matrix]-object with the format:
#'
#' \describe{
#'  \item{upper}{[double]. The lower band.}
#'  \item{middle}{[double]. The middle band.}
#'  \item{lower}{[double]. The upper band.}
#' }
#'
#' @template description
parabolic_sar <- function(
	x,
	cols,
	acceleration = 0.02,
	maximum = 0.2,
	...
) {
	UseMethod(
		generic = "parabolic_sar"
	)
}

#' @export
#'
#' @usage NULL
#'
#' @rdname parabolic_sar
#' @aliases parabolic_sar
SAR <- parabolic_sar

#' @usage NULL
#' @aliases parabolic_sar
#' @export
parabolic_sar.default <- function(
	x,
	cols,
	acceleration = 0.02,
	maximum = 0.2,
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

	## default behaviour is to
	## coerce to a `matrix` check that
	## it is double and then pass to
	## C-side.
	HL <- series(
		x = cols,
		default = ~ high + low,
		data = x,
		...
	)

	## 1) pass `x` assuming that it
	##    follows OHLC-V structure
	output <- as.data.frame(
		.Call(
			"impl_ta_SAR",
			HL[[1]],
			HL[[2]],
			as.double(acceleration),
			as.double(maximum)
		)
	)

	colnames(output)[1] <- "SAR"

	return(output)
}

#' @usage NULL
#' @aliases parabolic_sar
#' @export
parabolic_sar.data.frame <- function(
	x,
	cols,
	acceleration = 0.02,
	maximum = 0.2,
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases parabolic_sar
#' @export
parabolic_sar.matrix <- function(
	x,
	cols,
	acceleration = 0.02,
	maximum = 0.2,
	...
) {
	as.matrix(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases parabolic_sar
#' @export
parabolic_sar.plotly <- function(
	x,
	cols,
	acceleration = 0.02,
	maximum = 0.2,
	...
) {
	## prepare series
	## from
	HL <- series(
		x = x,
		formula = cols,
		default = ~ high + low,
		...
	)

	.indicator <- as.data.frame(
		.Call(
			"impl_ta_SAR",
			HL[[1]],
			HL[[2]],
			as.double(acceleration),
			as.double(maximum)
		)
	)

	colnames(.indicator)[1] <- "SAR"

	.indicator$idx <- 1:nrow(.indicator)

	## calculate colors for
	## the chart

	## identify bullish
	## signals
	bull <- (.indicator$SAR < as.numeric(HL[[2L]]))

	## determine colors
	##
	colors <- ifelse(
		bull,
		plotly::toRGB(chart.theme()$bull_color, alpha = 0.8),
		plotly::toRGB(chart.theme()$bear_color, alpha = 0.8)
	)

	## constuct chart
	## element
	.plotting_environment$main <- plotly::add_trace(
		.plotting_environment$main,
		data = .indicator,
		x = ~idx,
		y = ~SAR,
		type = "scatter",
		mode = "markers",
		name = sprintf(
			"PSAR(%f,%f)",
			acceleration,
			maximum
		),
		inherit = FALSE,
		marker = list(
			size = 5,
			color = colors,
			line = list(
				color = "black",
				width = 1
			)
		)
	)

	.plotting_environment$main
}
