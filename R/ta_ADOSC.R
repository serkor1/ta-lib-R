#' @export
#' @family Volume Indicator
#'
#' @title Chaikin A/D Oscillator
#' @templateVar .title Chaikin A/D Oscillator
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun chaikin_accumulation_distribution_oscillator
#' @templateVar .family Volume Indicator
#' @templateVar .formula ~high+low+close+volume
#'
## splice:documentation:start
#' @param fast ([integer]). Period for the fast Moving Average (MA).
#' @param slow ([integer]). Period for the slow Moving Average (MA).
## splice:documentation:end
#'
#' @template description
#' @template returns
chaikin_accumulation_distribution_oscillator <- function(
	x,
	cols,
	fast = 3,
	slow = 10,
	na.bridge = FALSE,
	...
) {
	UseMethod("chaikin_accumulation_distribution_oscillator")
}

#' @export
#' @usage NULL
#' @rdname chaikin_accumulation_distribution_oscillator
#'
#' @aliases chaikin_accumulation_distribution_oscillator
ADOSC <- chaikin_accumulation_distribution_oscillator

#' @usage NULL
#' @aliases chaikin_accumulation_distribution_oscillator
#'
#' @export
chaikin_accumulation_distribution_oscillator.default <- function(
	x,
	cols,
	fast = 3,
	slow = 10,
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
		C_impl_ta_ADOSC,
		## splice:call:start
		constructed_series[[1]],
		constructed_series[[2]],
		constructed_series[[3]],
		constructed_series[[4]],
		as.integer(fast),
		as.integer(slow),
		## splice:call:end
		as.logical(na.bridge)
	)

	## readd rownames
	set_rownames(x, x_names)

	## return indicator
	x
}

#' @usage NULL
#' @aliases chaikin_accumulation_distribution_oscillator
#'
#' @export
chaikin_accumulation_distribution_oscillator.data.frame <- function(
	x,
	cols,
	fast = 3,
	slow = 10,
	na.bridge = FALSE,
	...
) {
	map_dfr(
		chaikin_accumulation_distribution_oscillator.default(
			x = x,
			cols = cols,
			fast = fast,
			slow = slow,
			na.bridge = na.bridge,
			...
		)
	)
}

#' @usage NULL
#' @aliases chaikin_accumulation_distribution_oscillator
#'
#' @export
chaikin_accumulation_distribution_oscillator.matrix <- function(
	x,
	cols,
	fast = 3,
	slow = 10,
	na.bridge = FALSE,
	...
) {
	chaikin_accumulation_distribution_oscillator.default(
		x = x,
		cols = cols,
		fast = fast,
		slow = slow,
		na.bridge = na.bridge,
		...
	)
}


#' @usage NULL
#' @aliases chaikin_accumulation_distribution_oscillator
#'
#' @export
chaikin_accumulation_distribution_oscillator.plotly <- function(
	x,
	cols,
	fast = 3,
	slow = 10,
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
		default = ~ high + low + close + volume,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- chaikin_accumulation_distribution_oscillator(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		fast = fast,
		slow = slow,
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
	name <- sprintf("ADOSC(%d, %d)", fast, slow)
	decorators <- list()
	traces <- list(
		list(y = ~ADOSC)
	)
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
				"Chaikin A/D Oscillator"
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
#' @aliases chaikin_accumulation_distribution_oscillator
#'
#' @export
chaikin_accumulation_distribution_oscillator.ggplot <- function(
	x,
	cols,
	fast = 3,
	slow = 10,
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
		default = ~ high + low + close + volume,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- chaikin_accumulation_distribution_oscillator(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		fast = fast,
		slow = slow,
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
	layers <- lapply(
		setdiff(colnames(constructed_indicator), "idx"),
		function(col) list(y = col)
	)
	name <- sprintf("ADOSC(%d, %d)", fast, slow)
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
				"Chaikin A/D Oscillator"
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
