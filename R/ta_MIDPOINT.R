#' @export
#' @family Overlap Studies
#'
#' @title MidPoint over period
#' @templateVar .title MidPoint over period
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun midpoint_period
#' @templateVar .family Overlap Studies
#' @templateVar .formula ~close
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
#'
#' @template returns
midpoint_period <- function(
	x,
	cols,
	timePeriod = 14,
	na.bridge = FALSE,
	...) {
  UseMethod("midpoint_period")
}

#' @export
#' @usage NULL
#' @rdname midpoint_period
#'
#' @aliases midpoint_period
MIDPOINT <- midpoint_period

#' @usage NULL
#' @aliases midpoint_period
#'
#' @export
midpoint_period.default <- function(
	x,
	cols,
	timePeriod = 14,
	na.bridge = FALSE,
	...) {

	## validate 'cols'-argument
	## if explicitly passed
	if (!missing(cols)) {
		assert_formula(cols)
	}

	## construct series
	## from input
	constructed_series <- series(
		x = cols,
		default_formula = ~close,
		data = x,
		...
	)

	## extract rownames
	## for later attachment
	x_names <- rownames(constructed_series)

	## calculate indicator and
	## return as data.frame
	x <- .Call(
		C_impl_ta_MIDPOINT,
		constructed_series[[1]],
		as.integer(timePeriod),		
		as.logical(na.bridge)
	)

	## readd rownames
	set_rownames(x, x_names)

	## return indicator
	x
}

#' @usage NULL
#' @aliases midpoint_period
#'
#' @export
midpoint_period.data.frame <- function(
	x,
	cols,
	timePeriod = 14,
	na.bridge = FALSE,
	...
) {
	map_dfr(
		midpoint_period.default(
			x = x,
			cols = cols,
			timePeriod = timePeriod,
			na.bridge = na.bridge,
			...
		)
	)

}

#' @usage NULL
#' @aliases midpoint_period
#'
#' @export
midpoint_period.matrix <- function(
	x,
	cols,
	timePeriod = 14,
	na.bridge = FALSE,
	...) {

	midpoint_period.default(
			x = x,
			cols = cols ,
			timePeriod = timePeriod,
			na.bridge = na.bridge,
			...
		)
}

#' @usage NULL
MIDPOINT_lookback <- midpoint_period_lookback <- function(
	x,
	cols,
	timePeriod = 14,
	na.bridge = FALSE,
	...
) {

	.Call(
		C_impl_ta_MIDPOINT_lookback,
		as.integer(timePeriod)
	)

}

#' @usage NULL
#' @aliases midpoint_period
#'
#' @export
midpoint_period.numeric <- function(
	x,
	cols,
	timePeriod = 14,
	na.bridge = FALSE,
	...) {

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
		C_impl_ta_MIDPOINT,
		as.double(x),
		as.integer(timePeriod),
		as.logical(na.bridge)
	)

	if (dim(x)[2] == 1L) {
		dim(x) <- NULL
	}

	x
}

#' @usage NULL
#' @aliases midpoint_period
#'
#' @export
midpoint_period.plotly <- function(
	x,
	cols,
	timePeriod = 14,
	na.bridge = FALSE,
	## splice:optional-plotly:start
	## splice:optional-plotly:end
	...) {

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
		default_formula = ~close,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- midpoint_period(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		timePeriod = timePeriod,
		na.bridge = TRUE
	)

	## add conditional idx
	constructed_indicator[["idx"]] <- add_idx(
		constructed_series
	)

	## construct {plotly}-object
	## splice:plotly-assembly:start
	traces <- lapply(
		setdiff(colnames(constructed_indicator), "idx"),
		function(col) {
			list(
				y = stats::as.formula(
					paste0("~", col)
				),
				name = col
			)
		}
	)
	name <- "MIDPOINT"
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
#' @aliases midpoint_period
#'
#' @export
midpoint_period.ggplot <- function(
	x,
	cols,
	timePeriod = 14,
	na.bridge = FALSE,
	## splice:optional-ggplot:start
	## splice:optional-ggplot:end
	...) {

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
		default_formula = ~close,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- midpoint_period(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		timePeriod = timePeriod,
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
	name <- "MIDPOINT"
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
