#' @export
#' @family Volume Indicator
#'
#' @title Trading Volume
#' @templateVar .title Trading Volume
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun trading_volume
#' @templateVar .family Volume Indicator
#' @templateVar .formula ~volume + open + close
#'
## splice:documentation:start
#' @param ma A list of MA specifications.
## splice:documentation:end
#'
#' @template description
#' @template returns
trading_volume <- function(
	x,
	cols,
	ma = list(SMA(n = 7), SMA(n = 15)),
	na.bridge = FALSE,
	...
) {
	UseMethod("trading_volume")
}

#' @export
#' @usage NULL
#' @rdname trading_volume
#'
#' @aliases trading_volume
VOLUME <- trading_volume

#' @usage NULL
#' @aliases trading_volume
#'
#' @export
trading_volume.default <- function(
	x,
	cols,
	ma = list(SMA(n = 7), SMA(n = 15)),
	na.bridge = FALSE,
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
		default = ~ volume + open + close,
		data = x,
		...
	)

	## extract rownames
	## for later attachment
	x_names <- rownames(constructed_series)

	## calculate indicator and
	## return as data.frame
	x <- .Call(
		C_impl_ta_VOLUME,
		## splice:call:start
		as.double(constructed_series[[1]]),
		lapply(
			ma,
			function(x) {
				as.integer(
					unlist(x, use.names = FALSE)
				)
			}
		),
		## splice:call:end
		as.logical(na.bridge)
	)

	## readd rownames
	set_rownames(x, x_names)

	## return indicator
	x
}

#' @usage NULL
#' @aliases trading_volume
#'
#' @export
trading_volume.data.frame <- function(
	x,
	cols,
	ma = list(SMA(n = 7), SMA(n = 15)),
	na.bridge = FALSE,
	...
) {
	map_dfr(
		trading_volume.default(
			x = x,
			cols = cols,
			ma = ma,
			na.bridge = na.bridge,
			...
		)
	)
}

#' @usage NULL
#' @aliases trading_volume
#'
#' @export
trading_volume.matrix <- function(
	x,
	cols,
	ma = list(SMA(n = 7), SMA(n = 15)),
	na.bridge = FALSE,
	...
) {
	trading_volume.default(
		x = x,
		cols = cols,
		ma = ma,
		na.bridge = na.bridge,
		...
	)
}


#' @usage NULL
#' @aliases trading_volume
#'
#' @export
trading_volume.numeric <- function(
	x,
	cols,
	ma = list(SMA(n = 7), SMA(n = 15)),
	na.bridge = FALSE,
	...
) {
	## warn if 'cols' have been
	## passed just to make sure
	## the user knows its not possible
	## or relevant
	if (!missing(cols)) {
		warning("'cols' is passed but is unused for vectors.")
	}

	## pass the argument directly
	## to 'C'
	x <- .Call(
		C_impl_ta_VOLUME,
		## splice:numeric:start
		as.double(x),
		ma,
		## splice:numeric:end
		as.logical(na.bridge)
	)

	## check if it has 'dims'
	## and convert to double if
	## not to honor the 'type-safety'-esque
	## approach
	##
	## NOTE: this adds a few ns overhead but
	##       its a robust alternative to code it
	##       manually. Any suggestions are welcome
	if (is.null(dim(x))) {
		x <- as.double(x)
	}

	x
}


#' @usage NULL
#' @aliases trading_volume
#'
#' @export
trading_volume.plotly <- function(
	x,
	cols,
	ma = list(SMA(n = 7), SMA(n = 15)),
	na.bridge = FALSE,
	## splice:optional-plotly:start
	## splice:optional-plotly:end
	title,
	...
) {
	## check that input value
	## 'x' is <plotly>-object
	assert_plotly_object(x)

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
		default = ~ volume + open + close,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- trading_volume(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		ma = ma,
		na.bridge = TRUE
	)

	## the constructed indicator
	## always returns excpected
	## columns which can be passed
	## down to add_last_values()
	values_to_extract <- colnames(constructed_indicator)

	## add conditional idx
	constructed_indicator[["idx"]] <- add_idx(
		constructed_series
	)

	## construct {plotly}-object
	## splice:plotly-assembly:start

	## calculate direction of the
	## candle for downstream coloring
	##
	## NOTE: this might a possible bug
	##       if values are passed differently
	##       form 'open' and 'close'
	constructed_indicator$direction <- constructed_series$open >=
		constructed_series$close

	## construct theme object for
	## coloring
	## identify column names
	## that are not 'idx' or 'direction'
	trace_cols <- setdiff(
		names(constructed_indicator),
		c("idx", "direction")
	)

	## construct all traces
	traces <- lapply(
		trace_cols,
		function(col) {
			list(
				y = stats::as.formula(
					paste0("~", col)
				),

				## reformat extract SMA17 as SMA(17)
				name = sub(
					"^([A-Za-z]+)([0-9]+)$",
					"\\1(\\2)",
					col,
					perl = TRUE
				)
			)
		}
	)

	## modify the first trace
	## assuming its volume
	traces[[1]]$color <- ~direction
	traces[[1]]$colors = c(
		.chart_variables$bullish_body,
		.chart_variables$bearish_body
	)
	traces[[1]]$showlegend <- FALSE
	traces[[1]]$type <- 'bar'
	traces[[1]]["mode"] <- list(NULL)
	## splice:plotly-assembly:end

	plotly_object <- add_last_value_ly(
		build_plotly(
			init = plotly_init(),
			traces = traces,
			decorators = get0(
				x = "decorators",
				ifnotfound = list()
			),
			name = get0(
				x = "name",
				ifnotfound = NULL
			),
			data = constructed_indicator,
			title = if (missing(title)) {
				"Trading Volume"
			} else {
				title
			}
		),
		data = constructed_indicator[, values_to_extract, drop = FALSE],
		values_to_extract = values_to_extract
	)

	state <- .chart_state()
	state$sub <- c(state$sub, list(plotly_object))

	plotly_object
}

#' @usage NULL
#' @aliases trading_volume
#'
#' @export
trading_volume.ggplot <- function(
	x,
	cols,
	ma = list(SMA(n = 7), SMA(n = 15)),
	na.bridge = FALSE,
	## splice:optional-ggplot:start
	## splice:optional-ggplot:end
	title,
	...
) {
	## check ggplot2 availability
	assert_ggplot2()

	## check that input value
	## 'cols' is a <formula>-objet
	if (!missing(cols)) {
		assert_formula(cols)
	}

	## construct series from
	## {ggplot}-object
	constructed_series <- series(
		x = x,
		formula = cols,
		default = ~ volume + open + close,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- trading_volume(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		ma = ma,
		na.bridge = TRUE
	)

	## the constructed indicator
	## always returns expected
	## columns which can be passed
	## down to add_last_value_gg()
	values_to_extract <- colnames(constructed_indicator)

	## add conditional idx
	constructed_indicator[["idx"]] <- add_idx(
		constructed_series
	)

	## construct {ggplot2}-object
	## splice:ggplot-assembly:start
	constructed_indicator$direction <- constructed_series$open >=
		constructed_series$close
	trace_cols <- setdiff(
		colnames(constructed_indicator),
		c("idx", "direction")
	)
	layers <- list(
		list(
			y = trace_cols[1],
			geom = "bar",
			direction = "direction"
		)
	)
	if (length(trace_cols) > 1L) {
		for (col in trace_cols[-1]) {
			layers <- c(
				layers,
				list(list(
					y = col,
					name = sub(
						"^([A-Za-z]+)([0-9]+)$",
						"\\1(\\2)",
						col,
						perl = TRUE
					)
				))
			)
		}
	}
	name <- "Volume"
	## splice:ggplot-assembly:end

	ggplot_object <- add_last_value_gg(
		build_ggplot(
			init = ggplot_init(),
			layers = layers,
			decorators = get0(
				x = "decorators",
				ifnotfound = list()
			),
			name = get0(
				x = "name",
				ifnotfound = NULL
			),
			data = constructed_indicator,
			title = if (missing(title)) {
				"Trading Volume"
			} else {
				title
			}
		),
		data = constructed_indicator[, values_to_extract, drop = FALSE],
		values_to_extract = values_to_extract,
		name = get0(x = "name", ifnotfound = NULL)
	)

	state <- .chart_state()
	state$sub <- c(state$sub, list(ggplot_object))

	ggplot_object
}
