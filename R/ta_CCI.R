#' @export
#' @family Momentum Indicator
#'
#' @title Commodity Channel Index
#' @templateVar .title Commodity Channel Index
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun commodity_channel_index
#' @templateVar .family Momentum Indicator
#' @templateVar .formula ~ high + low + close
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
#' @template returns
commodity_channel_index <- function(
	x,
	cols,
	n = 10,
	...
) {
	UseMethod("commodity_channel_index")
}

#' @export
#' @usage NULL
#' @rdname commodity_channel_index
#'
#' @aliases commodity_channel_index
CCI <- commodity_channel_index

#' @usage NULL
#' @aliases commodity_channel_index
#'
#' @export
commodity_channel_index.default <- function(
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
		"impl_ta_CCI",
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
#' @aliases commodity_channel_index
#'
#' @export
commodity_channel_index.data.frame <- function(
	x,
	cols,
	n = 10,
	...
) {
	map_dfr(
		commodity_channel_index.default(
			x = x,
			cols = cols,
			n = n,
			...
		)
	)
}

#' @usage NULL
#' @aliases commodity_channel_index
#'
#' @export
commodity_channel_index.matrix <- function(
	x,
	cols,
	n = 10,
	...
) {
	commodity_channel_index.default(
		x = x,
		cols = cols,
		n = n,
		...
	)
}

#' @usage NULL
#' @aliases commodity_channel_index
#'
#' @export
commodity_channel_index.plotly <- function(
	x,
	cols,
	n = 10,
	## splice:optional-plotly:start
	lower_bound = -100,
	upper_bound = 100,
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
		default = ~ high + low + close,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- commodity_channel_index(
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
	name <- sprintf(
		"CCI(%d)",
		n
	)
	traces <- list(
		plotly_line(lower_bound, nrow(constructed_indicator)),
		plotly_line(upper_bound, nrow(constructed_indicator)),
		list(y = ~CCI)
	)
	## splice:plotly-assembly:end

	plotly_object <- .plotting_environment[["main"]] <- build_plotly(
		init = .plotting_environment[["main"]],
		traces = traces,
		decorators = list(),
		name = get0(
			x = "name",
			ifnotfound = NULL
		),
		data = constructed_indicator
	)

	plotly_object
}
