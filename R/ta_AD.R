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

#' @export
#'
#' @usage NULL
#'
#' @rdname chaikin_AD_line
#' @aliases chaikin_AD_line
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
	## for the chaikin A/D line
	HLCV <- series(
		x = x,
		formula = cols,
		default = ~ high + low + close + volume,
		...
	)

	## calculate indicator
	## and return as data.grame
	.indicator <- chaikin_AD_line.default(
		x = HLCV,
		cols = rebuild_formula(
			names(HLCV)
		)
	)

	## add x-axis conditional on whether
	## the data have been subsetted or not
	.indicator$idx <- add_idx(
		HLCV
	)

	## construct chart
	## element
	plotly_object <- subchart(
		data = .indicator,
		y = ~AD_line,
		type = "scatter",
		mode = "lines",
		showlegend = FALSE
	)

	if (main_chart_exists()) {
		plotly_object <- add_title(
			x = plotly_object,
			text = "Chaikin A/D Line"
		)
	}

	.plotting_environment$sub <- c(
		.plotting_environment$sub,
		list(plotly_object)
	)

	plotly_object
}
