#' @export
#' @family Volatility Indicator
#'
#' @title True Range
#' @templateVar .title True Range
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun true_range
#' @templateVar .family Volatility Indicator
#' @templateVar .formula ~high + low + close
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
#' @template returns
true_range <- function(
	x,
	cols,
	...
) {
	UseMethod("true_range")
}

#' @export
#' @usage NULL
#' @rdname true_range
#'
#' @aliases true_range
TRANGE <- true_range

#' @usage NULL
#' @aliases true_range
#'
#' @export
true_range.default <- function(
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
		"impl_ta_TRANGE",
		## splice:call:start
		constructed_series[[1]],
		constructed_series[[2]],
		constructed_series[[3]]
		## splice:call:end
	)

	## readd rownames
	set_rownames(x, x_names)

	## return indicator
	x
}

#' @usage NULL
#' @aliases true_range
#'
#' @export
true_range.data.frame <- function(
	x,
	cols,
	...
) {
	map_dfr(
		true_range.default(
			x = x,
			cols = cols,
			...
		)
	)
}

#' @usage NULL
#' @aliases true_range
#'
#' @export
true_range.matrix <- function(
	x,
	cols,
	...
) {
	true_range.default(
		x = x,
		cols = cols,
		...
	)
}

#' @usage NULL
#' @aliases true_range
#'
#' @export
true_range.plotly <- function(
	x,
	cols,
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
	constructed_indicator <- true_range(
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
	name <- sprintf("TRANGE")
	decorators <- list()
	traces <- list(
		list(y = ~TRANGE)
	)
	## splice:plotly-assembly:end

	plotly_object <- build_plotly(
		init = plotly_init(),
		traces = traces,
		decorators = get0(
			x = "decorators",
			ifnotfound = list()
		),
		name = name,
		data = constructed_indicator,
		title = if (missing(title)) {
			"True Range"
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
