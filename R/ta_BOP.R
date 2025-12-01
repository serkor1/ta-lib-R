#' @export
#' @family Momentum Indicator
#'
#' @title Balance of Power
#' @templateVar .title Balance of Power
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun balance_of_power
#' @templateVar .family Momentum Indicator
#' @templateVar .formula ~ open + high + low + close
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
#' @template returns
balance_of_power <- function(
	x,
	cols,
	...
) {
	UseMethod("balance_of_power")
}

#' @export
#' @usage NULL
#' @rdname balance_of_power
#'
#' @aliases balance_of_power
BOP <- balance_of_power

#' @usage NULL
#' @aliases balance_of_power
#'
#' @export
balance_of_power.default <- function(
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
		default = ~ open + high + low + close,
		data = x,
		...
	)

	## extract rownames
	## for later attachment
	x_names <- rownames(constructed_series)

	## calculate indicator and
	## return as data.frame
	x <- .Call(
		"impl_ta_BOP",
		## splice:call:start
		constructed_series[[1]],
		constructed_series[[2]],
		constructed_series[[3]],
		constructed_series[[4]]
		## splice:call:end
	)

	## readd rownames
	set_rownames(x, x_names)

	## return indicator
	x
}

#' @usage NULL
#' @aliases balance_of_power
#'
#' @export
balance_of_power.data.frame <- function(
	x,
	cols,
	...
) {
	map_dfr(
		balance_of_power.default(
			x = x,
			cols = cols,
			...
		)
	)
}

#' @usage NULL
#' @aliases balance_of_power
#'
#' @export
balance_of_power.matrix <- function(
	x,
	cols,
	...
) {
	balance_of_power.default(
		x = x,
		cols = cols,
		...
	)
}

#' @usage NULL
#' @aliases balance_of_power
#'
#' @export
balance_of_power.plotly <- function(
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
		default = ~ open + high + low + close,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- balance_of_power(
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
	name <- "BOP"

	traces <- list(
		list(y = ~BOP)
	)
	## splice:plotly-assembly:end

	plotly_object <- build_plotly(
		init = plotly_init(),
		traces = traces,
		name = name,
		data = constructed_indicator,
		title = if (missing(title)) {
			"Balance of Power"
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
