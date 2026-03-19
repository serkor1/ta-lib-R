#' @export
#' @family Volume Indicator
#'
#' @title On-Balance Volume
#' @templateVar .title On-Balance Volume
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun on_balance_volume
#' @templateVar .family Volume Indicator
#' @templateVar .formula ~close+volume
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
#' @template returns
on_balance_volume <- function(
	x,
	cols,
	na.rm = FALSE,
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
	na.rm = FALSE,
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
		constructed_series[[2]],
		## splice:call:end
		,
		as.logical(na.rm)
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
	na.rm = FALSE,
	...
) {
	map_dfr(
		on_balance_volume.default(
			x = x,
			cols = cols,
			na.rm = na.rm,
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
	na.rm = FALSE,
	...
) {
	on_balance_volume.default(
		x = x,
		cols = cols,
		na.rm = na.rm,
		...
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
	na.rm = FALSE,
	title,
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

	## the constructed indicator
	## always returns excpected
	## columns which can be passed
	## down to add_last_values()
	values_to_extract <- colnames(constructed_indicator)

	## add conditional idx
	constructed_indicator[["idx"]] <- add_idx(
		constructed_series
	)

	## construct {plotly}-object
	## splice:plotly-assembly:start
	name <- "OBV"
	traces <- list(list(y = ~OBV))
	## splice:plotly-assembly:end

	plotly_object <- add_last_value(
		build_plotly(
			init = plotly_init(),
			traces = traces,
			decorators = get0(
				x = "decorators",
				ifnotfound = list()
			),
			name = get0(
				x = "name",
				ifnotfound = NULL
			),
			data = constructed_indicator,
			title = if (missing(title)) {
				"On-Balance Volume"
			} else {
				title
			}
		),
		data = constructed_indicator[, values_to_extract, drop = FALSE],
		values_to_extract = values_to_extract
	)

	.chart_environment$sub <- c(
		.chart_environment$sub,
		list(plotly_object)
	)

	plotly_object
}
