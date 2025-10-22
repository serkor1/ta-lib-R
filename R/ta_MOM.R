#' @export
#' @family Momentum Indicator
#'
#' @title Momentum
#' @templateVar .title Momentum
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun momentum
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
momentum <- function(
	x,
	cols,
	n = 10,
	...
) {
	UseMethod("momentum")
}

#' @export
#' @usage NULL
#' @rdname momentum
#'
#' @aliases momentum
MOM <- momentum

#' @usage NULL
#' @aliases momentum
#'
#' @export
momentum.default <- function(
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

	## extract rownames
	## for later attachment
	x_names <- rownames(x)

	## construct series
	## from input
	constructed_series <- series(
		x = cols,
		default = ~close,
		data = x,
		...
	)

	## calculate indicator and
	## return as data.frame
	x <- .Call(
		"impl_ta_MOM",
		## splice:call:start
		constructed_series[[1]],
		as.integer(n)
		## splice:call:end
	)

	## readd rownames
	rownames(x) <- x_names

	## return indicator
	x
}

#' @usage NULL
#' @aliases momentum
#'
#' @export
momentum.data.frame <- function(
	x,
	cols,
	n = 10,
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases momentum
#'
#' @export
momentum.matrix <- function(
	x,
	cols,
	n = 10,
	...
) {
	as.matrix(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases momentum
#'
#' @export
momentum.plotly <- function(
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
		default = ~close,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- momentum(
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
		y = ~MOM,
		type = "scatter",
		mode = "lines",
		showlegend = FALSE
	)

	if (main_chart_exists()) {
		plotly_object <- add_title(
			x = plotly_object,
			text = "Momentum"
		)
	}

	.plotting_environment$sub <- c(
		.plotting_environment$sub,
		list(plotly_object)
	)
	## splice:plotly-assembly:end

	plotly_object
}
