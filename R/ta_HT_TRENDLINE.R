#' @export
#' @family Overlap Study
#'
#' @title Hilbert Transform - Instantaneous Trendline
#' @templateVar .title Hilbert Transform - Instantaneous Trendline
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun trendline
#' @templateVar .family Overlap Study
#' @templateVar .formula ~close
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
#' @template returns
trendline <- function(
	x,
	cols,
	na.bridge = FALSE,
	...
) {
	UseMethod("trendline")
}

#' @export
#' @usage NULL
#' @rdname trendline
#'
#' @aliases trendline
HT_TRENDLINE <- trendline

#' @usage NULL
#' @aliases trendline
#'
#' @export
trendline.default <- function(
	x,
	cols,
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
		default = ~close,
		data = x,
		...
	)

	## extract rownames
	## for later attachment
	x_names <- rownames(constructed_series)

	## calculate indicator and
	## return as data.frame
	x <- .Call(
		C_impl_ta_HT_TRENDLINE,
		## splice:call:start
		constructed_series[[1]],
		## splice:call:end
		as.logical(na.bridge)
	)

	## readd rownames
	set_rownames(x, x_names)

	## return indicator
	x
}

#' @usage NULL
#' @aliases trendline
#'
#' @export
trendline.data.frame <- function(
	x,
	cols,
	na.bridge = FALSE,
	...
) {
	map_dfr(
		trendline.default(
			x = x,
			cols = cols,
			na.bridge = na.bridge,
			...
		)
	)
}

#' @usage NULL
#' @aliases trendline
#'
#' @export
trendline.matrix <- function(
	x,
	cols,
	na.bridge = FALSE,
	...
) {
	trendline.default(
		x = x,
		cols = cols,
		na.bridge = na.bridge,
		...
	)
}


#' @usage NULL
#' @aliases trendline
#'
#' @export
trendline.numeric <- function(
	x,
	cols,
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
		C_impl_ta_HT_TRENDLINE,
		## splice:numeric:start
		as.double(x),
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
#' @aliases trendline
#'
#' @export
trendline.plotly <- function(
	x,
	cols,
	na.bridge = FALSE,
	## splice:optional-plotly:start
	## splice:optional-plotly:end
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
		default = ~close,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- trendline(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		na.bridge = TRUE
	)

	## add conditional idx
	constructed_indicator[["idx"]] <- add_idx(
		constructed_series
	)

	## construct {plotly}-object
	## splice:plotly-assembly:start
	name <- "Trendline"
	traces <- list(
		list(y = ~HT_TRENDLINE, name = "Trendline")
	)
	## splice:plotly-assembly:end

	state <- .chart_state()
	plotly_object <- build_plotly(
		init = state[["main"]],
		traces = traces,
		decorators = list(),
		name = get0(
			x = "name",
			ifnotfound = NULL
		),
		data = constructed_indicator
	)
	state[["main"]] <- plotly_object

	plotly_object
}

#' @usage NULL
#' @aliases trendline
#'
#' @export
trendline.ggplot <- function(
	x,
	cols,
	na.bridge = FALSE,
	## splice:optional-ggplot:start
	## splice:optional-ggplot:end
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
		default = ~close,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- trendline(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		na.bridge = TRUE
	)

	## add conditional idx
	constructed_indicator[["idx"]] <- add_idx(
		constructed_series
	)

	## construct {ggplot2}-object
	## splice:ggplot-assembly:start
	layers <- lapply(
		setdiff(colnames(constructed_indicator), "idx"),
		function(col) list(y = col)
	)
	name <- "Trendline"
	## splice:ggplot-assembly:end

	state <- .chart_state()
	ggplot_object <- build_ggplot(
		init = state[["main"]],
		layers = layers,
		decorators = list(),
		name = get0(
			x = "name",
			ifnotfound = NULL
		),
		data = constructed_indicator
	)
	state[["main"]] <- ggplot_object

	ggplot_object
}
