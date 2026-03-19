#' @export
#' @family Cycle Indicator
#'
#' @title Hilbert Transform - Trend vs Cycle Mode
#' @templateVar .title Hilbert Transform - Trend vs Cycle Mode
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun trend_cycle_mode
#' @templateVar .family Cycle Indicator
#' @templateVar .formula ~close
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
#' @template returns
trend_cycle_mode <- function(
	x,
	cols,
	na.rm = FALSE,
	...
) {
	UseMethod("trend_cycle_mode")
}

#' @export
#' @usage NULL
#' @rdname trend_cycle_mode
#'
#' @aliases trend_cycle_mode
HT_TRENDMODE <- trend_cycle_mode

#' @usage NULL
#' @aliases trend_cycle_mode
#'
#' @export
trend_cycle_mode.default <- function(
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
		default = ~close,
		data = x,
		...
	)

	## extract rownames
	## for later attachment
	x_names <- rownames(constructed_series)

	## calculate indicator and
	## return as data.frame
	x <- .Call(
		"impl_ta_HT_TRENDMODE",
		## splice:call:start
		constructed_series[[1]],
		## splice:call:end
		as.logical(na.rm)
	)

	## readd rownames
	set_rownames(x, x_names)

	## return indicator
	x
}

#' @usage NULL
#' @aliases trend_cycle_mode
#'
#' @export
trend_cycle_mode.data.frame <- function(
	x,
	cols,
	na.rm = FALSE,
	...
) {
	map_dfr(
		trend_cycle_mode.default(
			x = x,
			cols = cols,
			na.rm = na.rm,
			...
		)
	)
}

#' @usage NULL
#' @aliases trend_cycle_mode
#'
#' @export
trend_cycle_mode.matrix <- function(
	x,
	cols,
	na.rm = FALSE,
	...
) {
	trend_cycle_mode.default(
		x = x,
		cols = cols,
		na.rm = na.rm,
		...
	)
}


#' @usage NULL
#' @aliases trend_cycle_mode
#'
#' @export
trend_cycle_mode.numeric <- function(
	x,
	cols,
	na.rm = FALSE,
	...
) {
	## warn if 'cols' have been
	## passed just to make sure
	## the user knows its not possible
	## or relevant
	if (!missing(cols)) {
		warning("'cols' is passed but is unused for vectors.")
	}

	## pass the argument directly
	## to 'C'
	x <- .Call(
		"impl_ta_HT_TRENDMODE",
		## splice:numeric:start
		as.double(x),
		## splice:numeric:end
		as.logical(na.rm)
	)

	## check if it has 'dims'
	## and convert to double if
	## not to honor the 'type-safety'-esque
	## approach
	##
	## NOTE: this adds a few ns overhead but
	##       its a robust alternative to code it
	##       manually. Any suggestions are welcome
	if (is.null(dim(x))) {
		x <- as.double(x)
	}

	x
}


#' @usage NULL
#' @aliases trend_cycle_mode
#'
#' @export
trend_cycle_mode.plotly <- function(
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
		default = ~close,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- trend_cycle_mode(
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
	name <- sprintf("Trendmode")
	decorators <- list()
	traces <- list(
		list(
			y = ~HT_TRENDMODE,
			line = list(shape = "hvh"),
			name = "DC Period",
			legendgroup = name,
			legendgrouptitle = list(
				text = "Hilbert Transform - Trend vs Cycle Mode"
			)
		)
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
				"Hilbert Transform - Trend vs Cycle Mode"
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
