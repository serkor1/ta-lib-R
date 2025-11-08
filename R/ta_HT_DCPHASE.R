#' @export
#' @family Cycle Indicator
#'
#' @title Hilbert Transform - Dominant Cycle Phase
#' @templateVar .title Hilbert Transform - Dominant Cycle Phase
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun dominant_cycle_phase
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
#' @template returns
dominant_cycle_phase <- function(
	x,
	cols,
	...
) {
	UseMethod("dominant_cycle_phase")
}

#' @export
#' @usage NULL
#' @rdname dominant_cycle_phase
#'
#' @aliases dominant_cycle_phase
HT_DCPHASE <- dominant_cycle_phase

#' @usage NULL
#' @aliases dominant_cycle_phase
#'
#' @export
dominant_cycle_phase.default <- function(
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
		"impl_ta_HT_DCPHASE",
		## splice:call:start
		constructed_series[[1]]
		## splice:call:end
	)

	## readd rownames
	rownames(x) <- x_names

	## return indicator
	x
}

#' @usage NULL
#' @aliases dominant_cycle_phase
#'
#' @export
dominant_cycle_phase.data.frame <- function(
	x,
	cols,
	...
) {
	as.data.frame(
		dominant_cycle_phase.default(
			x = x,
			cols = cols,
			...
		)
	)
}

#' @usage NULL
#' @aliases dominant_cycle_phase
#'
#' @export
dominant_cycle_phase.matrix <- function(
	x,
	cols,
	...
) {
	as.matrix(
		dominant_cycle_phase.default(
			x = x,
			cols = cols,
			...
		)
	)
}

#' @usage NULL
#' @aliases dominant_cycle_phase
#'
#' @export
dominant_cycle_phase.numeric <- function(
	x,
	cols,
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
	## to dominant_cycle_phase.default()
	x <- dominant_cycle_phase.default(
		x = x,
		cols = cols,
		,
		...
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
#' @aliases dominant_cycle_phase
#'
#' @export
dominant_cycle_phase.plotly <- function(
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
		default = ~close,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- dominant_cycle_phase(
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
		y = ~HT_DCPHASE,
		type = "scatter",
		mode = "lines+markers",
		name = "DC Period"
	)

	if (main_chart_exists()) {
		plotly_object <- add_title(
			x = plotly_object,
			text = "Dominant Cycle Phase"
		)
	}

	.plotting_environment$sub <- c(
		.plotting_environment$sub,
		list(plotly_object)
	)
	## splice:plotly-assembly:end

	plotly_object
}
