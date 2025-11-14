#' @export
#' @family Momentum Indicator
#'
#' @title Money Flow Index
#' @templateVar .title Money Flow Index
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun money_flow_index
#' @templateVar .family Momentum Indicator
#' @templateVar .formula ~ high + low + close + volume
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
#' @template returns
money_flow_index <- function(
	x,
	cols,
	n = 10,
	...
) {
	UseMethod("money_flow_index")
}

#' @export
#' @usage NULL
#' @rdname money_flow_index
#'
#' @aliases money_flow_index
MFI <- money_flow_index

#' @usage NULL
#' @aliases money_flow_index
#'
#' @export
money_flow_index.default <- function(
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
		"impl_ta_MFI",
		## splice:call:start
		constructed_series[[1]],
		constructed_series[[2]],
		constructed_series[[3]],
		constructed_series[[4]],
		as.integer(n)
		## splice:call:end
	)

	## readd rownames
	set_rownames(x, x_names)

	## return indicator
	x
}

#' @usage NULL
#' @aliases money_flow_index
#'
#' @export
money_flow_index.data.frame <- function(
	x,
	cols,
	n = 10,
	...
) {
	map_dfr(
		money_flow_index.default(
			x = x,
			cols = cols,
			n = n,
			...
		)
	)
}

#' @usage NULL
#' @aliases money_flow_index
#'
#' @export
money_flow_index.matrix <- function(
	x,
	cols,
	n = 10,
	...
) {
	money_flow_index.default(
		x = x,
		cols = cols,
		n = n,
		...
	)
}

#' @usage NULL
#' @aliases money_flow_index
#'
#' @export
money_flow_index.plotly <- function(
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
		default = ~ high + low + close + volume,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- money_flow_index(
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
		y = ~MFI,
		type = "scatter",
		mode = "lines",
		showlegend = FALSE
	)

	plotly_object <- plotly::add_ribbons(
		plotly_object,
		x = ~idx,
		ymin = rep(-20, nrow(constructed_indicator)),
		ymax = rep(80, nrow(constructed_indicator)),
		line = list(width = 0),
		fillcolor = plotly::toRGB(
			x = "lightgray",
			alpha = 0.2
		)
	)

	if (main_chart_exists()) {
		plotly_object <- add_title(
			x = plotly_object,
			text = sprintf(
				"Money Flow Index (%d)",
				n
			)
		)
	}

	.plotting_environment$sub <- c(
		.plotting_environment$sub,
		list(plotly_object)
	)
	## splice:plotly-assembly:end

	plotly_object
}
