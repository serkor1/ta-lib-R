#' @export
#' @family Overlap Study
#'
#' @title Parabolic Stop and Reverse (SAR) - Extended
#'
#' @templateVar .title Parabolic Stop and Reverse (SAR) - Extended
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun extended_parabolic_sar
#'
#' @param start_value Start value and direction. 0 for Auto, >0 for Long, <0 for Short.
#' @param offset_on_reverse Percent offset added/removed to initial stop on short/long reversal
#' @param acceleration_init_long Acceleration Factor initial value for the Long direction
#' @param acceleration_long Acceleration Factor for the Long direction
#' @param acceleration_max_long Acceleration Factor maximum value for the Long direction
#' @param accelration_init_short Acceleration Factor initial value for the Short direction
#' @param acceleration_short Acceleration Factor for the Short direction
#' @param acceleration_max_short Acceleration Factor maximum value for the Short direction
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
extended_parabolic_sar <- function(
	x,
	cols,
	start_value = 0,
	offset_on_reverse = 0,
	acceleration_init_long = 0,
	acceleration_long = 0,
	acceleration_max_long = 0,
	accelration_init_short = 0,
	acceleration_short = 0,
	acceleration_max_short = 0,
	...
) {
	UseMethod(
		generic = "extended_parabolic_sar"
	)
}

#' @export
#'
#' @usage NULL
#'
#' @rdname extended_parabolic_sar
#' @aliases extended_parabolic_sar
SAREXT <- extended_parabolic_sar

#' @usage NULL
#' @aliases extended_parabolic_sar
#' @export
extended_parabolic_sar.default <- function(
	x,
	cols,
	start_value = 0,
	offset_on_reverse = 0,
	acceleration_init_long = 0,
	acceleration_long = 0,
	acceleration_max_long = 0,
	accelration_init_short = 0,
	acceleration_short = 0,
	acceleration_max_short = 0,
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
			"impl_ta_SAREXT",
			HL[[1]],
			HL[[2]],
			start_value,
			offset_on_reverse,
			acceleration_init_long,
			acceleration_long,
			acceleration_max_long,
			accelration_init_short,
			acceleration_short,
			acceleration_max_short
		)
	)

	colnames(output)[1] <- "SAR"

	return(output)
}

#' @usage NULL
#' @aliases extended_parabolic_sar
#' @export
extended_parabolic_sar.data.frame <- function(
	x,
	cols,
	start_value = 0,
	offset_on_reverse = 0,
	acceleration_init_long = 0,
	acceleration_long = 0,
	acceleration_max_long = 0,
	accelration_init_short = 0,
	acceleration_short = 0,
	acceleration_max_short = 0,
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases extended_parabolic_sar
#' @export
extended_parabolic_sar.matrix <- function(
	x,
	cols,
	start_value = 0,
	offset_on_reverse = 0,
	acceleration_init_long = 0,
	acceleration_long = 0,
	acceleration_max_long = 0,
	accelration_init_short = 0,
	acceleration_short = 0,
	acceleration_max_short = 0,
	...
) {
	as.matrix(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases extended_parabolic_sar
#' @export
extended_parabolic_sar.plotly <- function(
	x,
	cols,
	start_value = 0,
	offset_on_reverse = 0,
	acceleration_init_long = 0,
	acceleration_long = 0,
	acceleration_max_long = 0,
	accelration_init_short = 0,
	acceleration_short = 0,
	acceleration_max_short = 0,
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
			"impl_ta_SAREXT",
			HL[[1]],
			HL[[2]],
			start_value,
			offset_on_reverse,
			acceleration_init_long,
			acceleration_long,
			acceleration_max_long,
			accelration_init_short,
			acceleration_short,
			acceleration_max_short
		)
	)

	colnames(.indicator)[1] <- "SAR"

	## add x-axis conditional on whether
	## the data have been subsetted or not
	.indicator$idx <- add_idx(
		HL
	)

	## calculate colors for
	## the chart

	## identify bullish
	## signals
	bull <- (.indicator$SAR < as.numeric(HL[[2L]]))
	chart_theme <- .chart_theme()
	## determine colors
	##
	colors <- ifelse(
		bull,
		plotly::toRGB(chart_theme$bull_color, alpha = 0.8),
		plotly::toRGB(chart_theme$bear_color, alpha = 0.8)
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
			"EPSAR(%f,%f)",
			1,
			1
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
