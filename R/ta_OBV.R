#' @export
#' @family Volume Indicator
#'
#' @title On-Balance Volume
#' @templateVar .title On-Balance Volume
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun on_balance_volume
#' @templateVar .family Volume Indicator
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
#' @template returns
on_balance_volume <- function(
	x,
	cols,
	...
) {
	UseMethod("on_balance_volume")
}

#' @export
#' @usage NULL
#' @rdname on_balance_volume
#'
#' @aliases on_balance_volume
OBV <- on_balance_volume

#' @usage NULL
#' @aliases on_balance_volume
#'
#' @export
on_balance_volume.default <- function(
	x,
	cols,
	...
) {
	## validate 'cols'-argument
	## if explicitly passed
	if (!missing(cols)) {
		assert_formula(cols)
	}

	## construct series
	## from input
	constructed_series <- series(
		x = cols,
		default = ~ close + volume,
		data = x,
		...
	)

	## extract rownames
	## for later attachment
	x_names <- rownames(constructed_series)

	## calculate indicator and
	## return as data.frame
	x <- .Call(
		"impl_ta_OBV",
		## splice:call:start
		constructed_series[[1]],
		constructed_series[[2]]
		## splice:call:end
	)

	## readd rownames
	set_rownames(x, x_names)

	## return indicator
	x
}

#' @usage NULL
#' @aliases on_balance_volume
#'
#' @export
on_balance_volume.data.frame <- function(
	x,
	cols,
	...
) {
	as.data.frame(
		on_balance_volume.default(
			x = x,
			cols = cols,
			...
		)
	)
}

#' @usage NULL
#' @aliases on_balance_volume
#'
#' @export
on_balance_volume.matrix <- function(
	x,
	cols,
	...
) {
	as.matrix(
		on_balance_volume.default(
			x = x,
			cols = cols,
			...
		)
	)
}

#' @usage NULL
#' @aliases on_balance_volume
#'
#' @export
on_balance_volume.plotly <- function(
	x,
	cols,
	## splice:optional-plotly:start
	## splice:optional-plotly:end
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
		default = ~ close + volume,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- on_balance_volume(
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
	## splice:plotly-assembly:start
	plotly_object <- subchart(
		data = constructed_indicator,
		y = ~OBV,
		type = "scatter",
		mode = "lines",
		name = "On-Balance Volume",
		legendgroup = "obv",
		showlegend = TRUE
	)

	if (main_chart_exists()) {
		plotly_object <- add_title(
			x = plotly_object,
			text = "On-Balance Volume (OBV)"
		)
	}

	.plotting_environment$sub <- c(
		.plotting_environment$sub,
		list(plotly_object)
	)
	## splice:plotly-assembly:end

	plotly_object
}
