#' @export
#' @family Momentum Indicator
#'
#' @title Minus Directional Indicator
#' @templateVar .title Minus Directional Indicator
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun minus_directional_indicator
#' @templateVar .family Momentum Indicator
#' @templateVar .formula ~high + low + close
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
#' @template returns
minus_directional_indicator <- function(
	x,
	cols,
	n = 10,
	...
) {
	UseMethod("minus_directional_indicator")
}

#' @export
#' @usage NULL
#' @rdname minus_directional_indicator
#'
#' @aliases minus_directional_indicator
MINUS_DI <- minus_directional_indicator

#' @usage NULL
#' @aliases minus_directional_indicator
#'
#' @export
minus_directional_indicator.default <- function(
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
		default = ~ high + low + close,
		data = x,
		...
	)

	## extract rownames
	## for later attachment
	x_names <- rownames(constructed_series)

	## calculate indicator and
	## return as data.frame
	x <- .Call(
		"impl_ta_MINUS_DI",
		## splice:call:start
		constructed_series[[1]],
		constructed_series[[2]],
		constructed_series[[3]],
		as.integer(n)
		## splice:call:end
	)

	## readd rownames
	set_rownames(x, x_names)

	## return indicator
	x
}

#' @usage NULL
#' @aliases minus_directional_indicator
#'
#' @export
minus_directional_indicator.data.frame <- function(
	x,
	cols,
	n = 10,
	...
) {
	map_dfr(
		minus_directional_indicator.default(
			x = x,
			cols = cols,
			n = n,
			...
		)
	)
}

#' @usage NULL
#' @aliases minus_directional_indicator
#'
#' @export
minus_directional_indicator.matrix <- function(
	x,
	cols,
	n = 10,
	...
) {
	minus_directional_indicator.default(
		x = x,
		cols = cols,
		n = n,
		...
	)
}

#' @usage NULL
#' @aliases minus_directional_indicator
#'
#' @export
minus_directional_indicator.plotly <- function(
	x,
	cols,
	n = 10,
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
		default = ~ high + low + close,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- minus_directional_indicator(
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
	name <- sprintf("-DI(%d)", n)

	traces <- list(
		list(y = ~MINUS_DI)
	)
	## splice:plotly-assembly:end

	plotly_object <- build_plotly(
		init = plotly_init(),
		traces = traces,
		name = name,
		data = constructed_indicator,
		title = if (missing(title)) {
			"Minus Directional Indicator"
		} else {
			title
		}
	)

	.plotting_environment$sub <- c(
		.plotting_environment$sub,
		list(plotly_object)
	)

	plotly_object
}
