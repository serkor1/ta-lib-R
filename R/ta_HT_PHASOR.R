#' @export
#' @family Overlap Study
#'
#' @title Hilbert Transform - Phasor Components
#' @templateVar .title Hilbert Transform - Phasor Components
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun phasor_components
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
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
	x_names <- rownames(x)

	## calculate indicator and
	## return as data.frame
	x <- .Call(
		"impl_ta_HT_PHASOR",
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
#' @aliases phasor_components
#'
#' @export
phasor_components.data.frame <- function(
	x,
	cols,
	...
) {
	as.data.frame(
		NextMethod()
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
	as.matrix(
		NextMethod()
	)
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
		y = ~inphase,
		type = "scatter",
		mode = "lines",
		name = "Inphase",
		legendgroup = "phasor_components"
	)

	plotly_object <- plotly::add_lines(
		p = plotly_object,
		data = constructed_indicator,
		x = ~idx,
		y = ~quadrature,
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
