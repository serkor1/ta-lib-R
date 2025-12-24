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
		"impl_ta_VOLUME",
		## splice:call:start
		as.double(constructed_series[[1]]),
		lapply(
			ma,
			function(x) {
				as.integer(
					unlist(x, use.names = FALSE)
				)
			}
		)
		## splice:call:end
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
	...
) {
	map_dfr(
		trading_volume.default(
			x = x,
			cols = cols,
			ma = ma,
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
	...
) {
	trading_volume.default(
		x = x,
		cols = cols,
		ma = ma,
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
		"impl_ta_VOLUME",
		## splice:numeric:start
		as.double(x),
		ma
		## splice:numeric:end
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
		ma = ma
	)

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
	chart_theme <- layout_theme()

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
				name = col
			)
		}
	)

	## modify the first trace
	## assuming its volume
	traces[[1]]$color <- ~direction
	traces[[1]]$colors = c(
		chart_theme$bull_color,
		chart_theme$bear_color
	)
	traces[[1]]$type <- 'bar'
	traces[[1]]["mode"] <- list(NULL)
	## splice:plotly-assembly:end

	plotly_object <- build_plotly(
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
	)

	.plotting_environment$sub <- c(
		.plotting_environment$sub,
		list(plotly_object)
	)

	plotly_object
}
