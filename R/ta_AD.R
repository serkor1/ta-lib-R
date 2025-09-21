#' @export
#' @family Volume Indicator
#'
#' @title Chaikin A/D Line
#'
#' @templateVar .title Chaikin A/D Line
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun chaikin_AD_line
#'
#' @returns
#' A [data.frame]- or [matrix]-object:
#'
#' \describe{
#'  \item{AD_line <[double]>}{Chaikin A/D Line}
#' }
#'
#' @template description
chaikin_AD_line <- function(
	x,
	cols,
	...
) {
	UseMethod(
		"chaikin_AD_line"
	)
}

#' @usage NULL
#' @aliases chaikin_AD_line
#' @export
AD <- chaikin_AD_line

#' @usage NULL
#' @aliases chaikin_AD_line
#' @export
chaikin_AD_line.default <- function(
	x,
	cols,
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

	## pass values assuming
	## the series follows HLCV
	data.frame(
		AD_line = .Call(
			"impl_ta_AD",
			HLCV[[1]],
			HLCV[[2]],
			HLCV[[3]],
			HLCV[[4]]
		)
	)
}


#' @usage NULL
#' @aliases chaikin_AD_line
#' @export
chaikin_AD_line.data.frame <- function(
	x,
	cols,
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases chaikin_AD_line
#' @export
chaikin_AD_line.matrix <- function(
	x,
	cols,
	...
) {
	as.matrix(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases chaikin_AD_line
#' @export
chaikin_AD_line.plotly <- function(
	x,
	cols,
	...
) {
	## prepare HLCV series
	HLCV <- series(
		x = x,
		formula = cols,
		default = ~ high + low + close + volume,
		...
	)

	## construct the chaikin A/D
	## line and store as data.frame
	## for plotly
	.indicator <- data.frame(
		AD_line = .Call(
			"impl_ta_AD",
			HLCV[[1]],
			HLCV[[2]],
			HLCV[[3]],
			HLCV[[4]]
		)
	)

	## add idx for the axis
	## TODO: this should be passed
	## upstream instead
	.indicator$idx <- 1:nrow(.indicator)

	## chart indicator
	## as subplot
	output <- add_title(
		## generate plot
		## as line
		plotly::plot_ly(
			data = .indicator,
			x = ~idx,
			y = ~AD_line,
			type = "scatter",
			mode = "lines",
			showlegend = FALSE
		),
		## add title to
		## the plot
		text = "Chaikin A/D Line"
	)

	## pass to sub as
	## list to preserve
	## types
	.plotting_environment$sub <- c(
		.plotting_environment$sub,
		list(output)
	)

	## return plot
	## if called directly
	output
}
