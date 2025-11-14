#' @export
#' @family Cycle Indicator
#'
#' @title Hilbert Transform - Phasor Components
#' @templateVar .title Hilbert Transform - Phasor Components
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun phasor_components
#' @templateVar .family Cycle Indicator
#' @templateVar .formula ~close
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
#' @template returns
phasor_components <- function(
	x,
	cols,
	...
) {
	UseMethod("phasor_components")
}

#' @export
#' @usage NULL
#' @rdname phasor_components
#'
#' @aliases phasor_components
HT_PHASOR <- phasor_components

#' @usage NULL
#' @aliases phasor_components
#'
#' @export
phasor_components.default <- function(
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
		"impl_ta_HT_PHASOR",
		## splice:call:start
		constructed_series[[1]]
		## splice:call:end
	)

	## readd rownames
	set_rownames(x, x_names)

	## return indicator
	x
}

#' @usage NULL
#' @aliases phasor_components
#'
#' @export
phasor_components.data.frame <- function(
	x,
	cols,
	...
) {
	map_dfr(
		phasor_components.default(
			x = x,
			cols = cols,
			...
		)
	)
}

#' @usage NULL
#' @aliases phasor_components
#'
#' @export
phasor_components.matrix <- function(
	x,
	cols,
	...
) {
	phasor_components.default(
		x = x,
		cols = cols,
		...
	)
}

#' @usage NULL
#' @aliases phasor_components
#'
#' @export
phasor_components.numeric <- function(
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
	## to 'C'
	x <- .Call(
		"impl_ta_HT_PHASOR",
		## splice:numeric:start
		as.double(x)
		## splice:numeric:end
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
#' @aliases phasor_components
#'
#' @export
phasor_components.plotly <- function(
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
	constructed_indicator <- phasor_components(
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
		y = ~InPhase,
		type = "scatter",
		mode = "lines",
		name = "Inphase",
		legendgroup = "phasor_components"
	)

	plotly_object <- plotly::add_lines(
		p = plotly_object,
		data = constructed_indicator,
		x = ~idx,
		y = ~Quadrature,
		name = "Quadrature",
		legendgroup = "phasor_components"
	)

	if (main_chart_exists()) {
		plotly_object <- add_title(
			x = plotly_object,
			text = "Phasor Components"
		)
	}

	.plotting_environment$sub <- c(
		.plotting_environment$sub,
		list(plotly_object)
	)

	## splice:plotly-assembly:end

	plotly_object
}
