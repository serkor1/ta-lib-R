#' @export
#' @family Momentum Indicator
#'
#' @title Relative Strength Index
#' @templateVar .title Relative Strength Index
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun relative_strength_index
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
relative_strength_index <- function(
	x,
	cols,
	n = 10,
	...
) {
	UseMethod("relative_strength_index")
}

#' @export
#' @usage NULL
#' @rdname relative_strength_index
#'
#' @aliases relative_strength_index
RSI <- relative_strength_index

#' @usage NULL
#' @aliases relative_strength_index
#'
#' @export
relative_strength_index.default <- function(
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
		"impl_ta_RSI",
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
#' @aliases relative_strength_index
#'
#' @export
relative_strength_index.data.frame <- function(
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
#' @aliases relative_strength_index
#'
#' @export
relative_strength_index.matrix <- function(
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
#' @aliases relative_strength_index
#'
#' @export
relative_strength_index.plotly <- function(
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
	constructed_indicator <- relative_strength_index(
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
		y = ~RSI,
		type = "scatter",
		mode = "lines",
		showlegend = FALSE
	)

	plotly_object <- plotly::add_ribbons(
		plotly_object,
		x = ~idx,
		ymin = rep(20, nrow(constructed_indicator)),
		ymax = rep(80, nrow(constructed_indicator)),
		line = list(width = 0),
		fillcolor = plotly::toRGB(
			x = "lightgray",
			alpha = 0.2
		)
	)

	.plotting_environment$sub <- c(
		.plotting_environment$sub,
		list(plotly_object)
	)
	## splice:plotly-assembly:end

	plotly_object
}
