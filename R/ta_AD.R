#' @export
#' @family Volume Indicator
#'
#' @title Chaikin A/D Line
#' @templateVar .title Chaikin A/D Line
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun chaikin_AD_line
#'
#'
## input start
#' @returns
#' A [data.frame]- or [matrix]-object:
#'
#' \describe{
#'  \item{AD <[double]>}{Chaikin A/D Line}
#' }
#'
## input end
#'
#' @template description
chaikin_AD_line <- function(
	x,
	cols,
	...
) {
	UseMethod("chaikin_AD_line")
}

#' @export
#' @usage NULL
#' @rdname chaikin_AD_line
#'
#' @aliases chaikin_AD_line
AD <- chaikin_AD_line

#' @usage NULL
#' @aliases chaikin_AD_line
#'
#' @export
chaikin_AD_line.default <- function(
	x,
	cols,
	...
) {
	## validate 'cols'-argument
	## if explicitly passed
	if (!missing(cols)) {
		assert_formula(cols)
	}

	## extract rownames
	## for later attachment
	x_names <- rownames(x)

	## construct series
	## from input
	constructed_series <- series(
		x = cols,
		default = ~ high + low + close + volume,
		data = x,
		...
	)

	## calculate indicator and
	## return as data.frame
	x <- .Call(
		"impl_ta_AD",
		## input start
		constructed_series[[1]],
		constructed_series[[2]],
		constructed_series[[3]],
		constructed_series[[4]]
		## input end
	)

	## readd rownames
	rownames(x) <- x_names

	## return indicator
	return(x)
}

#' @usage NULL
#' @aliases chaikin_AD_line
#'
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
#'
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
#'
#' @export
chaikin_AD_line.plotly <- function(
	x,
	cols,
	...
) {
	## check that input value
	## 'x' is <plotly>-object
	assert_plotly(x)

	## check that input value
	## 'cols' is a <formula>-objet
	if (!missing(cols)) {
		assert_formula(cols)
	}

	## construct series from
	## {plotly}-object
	constructed_series <- series(
		x = x,
		formula = cols,
		default = ~ high + low + close + volume,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- chaikin_AD_line(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		)
	)

	## add conditional idx
	constructed_indicator[["idx"]] <- add_idx(
		constructed_series
	)

	## construct {plotly}-object
	## input start
	plotly_object <- subchart(
		data = constructed_indicator,
		y = ~AD,
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
	## input end

	plotly_object
}
