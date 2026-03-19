#' @export
#' @family Volume Indicator
#'
#' @title Chaikin A/D Line
#' @templateVar .title Chaikin A/D Line
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun chaikin_accumulation_distribution_line
#' @templateVar .family Volume Indicator
#' @templateVar .formula ~high+low+close+volume
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
#' @template returns
chaikin_accumulation_distribution_line <- function(
	x,
	cols,
	na.rm = FALSE,
	...
) {
	UseMethod("chaikin_accumulation_distribution_line")
}

#' @export
#' @usage NULL
#' @rdname chaikin_accumulation_distribution_line
#'
#' @aliases chaikin_accumulation_distribution_line
AD <- chaikin_accumulation_distribution_line

#' @usage NULL
#' @aliases chaikin_accumulation_distribution_line
#'
#' @export
chaikin_accumulation_distribution_line.default <- function(
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
		default = ~ high + low + close + volume,
		data = x,
		...
	)

	## extract rownames
	## for later attachment
	x_names <- rownames(constructed_series)

	## calculate indicator and
	## return as data.frame
	x <- .Call(
		"impl_ta_AD",
		## splice:call:start
		constructed_series[[1]],
		constructed_series[[2]],
		constructed_series[[3]],
		constructed_series[[4]],
		## splice:call:end
		as.logical(na.rm)
	)

	## readd rownames
	set_rownames(x, x_names)

	## return indicator
	x
}

#' @usage NULL
#' @aliases chaikin_accumulation_distribution_line
#'
#' @export
chaikin_accumulation_distribution_line.data.frame <- function(
	x,
	cols,
	na.rm = FALSE,
	...
) {
	map_dfr(
		chaikin_accumulation_distribution_line.default(
			x = x,
			cols = cols,
			na.rm = na.rm,
			...
		)
	)
}

#' @usage NULL
#' @aliases chaikin_accumulation_distribution_line
#'
#' @export
chaikin_accumulation_distribution_line.matrix <- function(
	x,
	cols,
	na.rm = FALSE,
	...
) {
	chaikin_accumulation_distribution_line.default(
		x = x,
		cols = cols,
		na.rm = na.rm,
		...
	)
}


#' @usage NULL
#' @aliases chaikin_accumulation_distribution_line
#'
#' @export
chaikin_accumulation_distribution_line.plotly <- function(
	x,
	cols,
	na.rm = FALSE,
	## splice:optional-plotly:start
	## splice:optional-plotly:end
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
		default = ~ high + low + close + volume,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- chaikin_accumulation_distribution_line(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		na.rm = TRUE
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
	name <- sprintf("AD")
	decorators <- list()
	traces <- list(
		list(y = ~AD)
	)
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
				"Chaikin A/D Line"
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
