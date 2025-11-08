#' @export
#' @family Momentum Indicator
#'
#' @title Intraday Movement Index
#' @templateVar .title Intraday Movement Index
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun intraday_movement_index
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
#' @template returns
intraday_movement_index <- function(
	x,
	cols,
	n = 10,
	...
) {
	UseMethod("intraday_movement_index")
}

#' @export
#' @usage NULL
#' @rdname intraday_movement_index
#'
#' @aliases intraday_movement_index
IMI <- intraday_movement_index

#' @usage NULL
#' @aliases intraday_movement_index
#'
#' @export
intraday_movement_index.default <- function(
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
		default = ~ open + close,
		data = x,
		...
	)

	## extract rownames
	## for later attachment
	x_names <- rownames(constructed_series)

	## calculate indicator and
	## return as data.frame
	x <- .Call(
		"impl_ta_IMI",
		## splice:call:start
		constructed_series[[1]],
		constructed_series[[2]],
		as.integer(n)
		## splice:call:end
	)

	## readd rownames
	rownames(x) <- x_names

	## return indicator
	x
}

#' @usage NULL
#' @aliases intraday_movement_index
#'
#' @export
intraday_movement_index.data.frame <- function(
	x,
	cols,
	n = 10,
	...
) {
	as.data.frame(
		intraday_movement_index.default(
			x = x,
			cols = cols,
			n = n,
			...
		)
	)
}

#' @usage NULL
#' @aliases intraday_movement_index
#'
#' @export
intraday_movement_index.matrix <- function(
	x,
	cols,
	n = 10,
	...
) {
	as.matrix(
		intraday_movement_index.default(
			x = x,
			cols = cols,
			n = n,
			...
		)
	)
}

#' @usage NULL
#' @aliases intraday_movement_index
#'
#' @export
intraday_movement_index.plotly <- function(
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
		default = ~ open + close,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- intraday_movement_index(
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
		y = ~IMI,
		type = "scatter",
		mode = "lines",
		showlegend = FALSE
	)

	if (main_chart_exists()) {
		plotly_object <- add_title(
			x = plotly_object,
			text = "Intraday Movement Index"
		)
	}

	.plotting_environment$sub <- c(
		.plotting_environment$sub,
		list(plotly_object)
	)
	## splice:plotly-assembly:end

	plotly_object
}
