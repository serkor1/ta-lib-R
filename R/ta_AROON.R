#' @export
#' @family Momentum Indicator
#'
#' @title Aroon
#' @templateVar .title Aroon
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun aroon
#' @templateVar .family Momentum Indicator
#' @templateVar .formula ~ high + low
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
#' @template returns
aroon <- function(
	x,
	cols,
	n = 10,
	...
) {
	UseMethod("aroon")
}

#' @export
#' @usage NULL
#' @rdname aroon
#'
#' @aliases aroon
AROON <- aroon

#' @usage NULL
#' @aliases aroon
#'
#' @export
aroon.default <- function(
	x,
	cols,
	n = 10,
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
		default = ~ high + low,
		data = x,
		...
	)

	## extract rownames
	## for later attachment
	x_names <- rownames(constructed_series)

	## calculate indicator and
	## return as data.frame
	x <- .Call(
		"impl_ta_AROON",
		## splice:call:start
		constructed_series[[1]],
		constructed_series[[2]],
		as.integer(n)
		## splice:call:end
	)

	## readd rownames
	set_rownames(x, x_names)

	## return indicator
	x
}

#' @usage NULL
#' @aliases aroon
#'
#' @export
aroon.data.frame <- function(
	x,
	cols,
	n = 10,
	...
) {
	map_dfr(
		aroon.default(
			x = x,
			cols = cols,
			n = n,
			...
		)
	)
}

#' @usage NULL
#' @aliases aroon
#'
#' @export
aroon.matrix <- function(
	x,
	cols,
	n = 10,
	...
) {
	aroon.default(
		x = x,
		cols = cols,
		n = n,
		...
	)
}

#' @usage NULL
#' @aliases aroon
#'
#' @export
aroon.plotly <- function(
	x,
	cols,
	n = 10,
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
		default = ~ high + low,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- aroon(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		n = n
	)

	## add conditional idx
	constructed_indicator[["idx"]] <- add_idx(
		constructed_series
	)

	## construct {plotly}-object
	## splice:plotly-assembly:start
	plotly_object <- subchart(
		data = constructed_indicator,
		y = ~AroonDown,
		type = "scatter",
		mode = "lines",
		name = "AD",
		legendgroup = "Aroon",
		showlegend = FALSE
	)

	plotly_object <- plotly::add_lines(
		p = plotly_object,
		x = ~idx,
		y = ~AroonUp,
		showlegend = FALSE,
		legendgroup = "Aroon",
		data = constructed_indicator
	)

	.plotting_environment$sub <- c(
		.plotting_environment$sub,
		list(plotly_object)
	)
	## splice:plotly-assembly:end

	plotly_object
}
