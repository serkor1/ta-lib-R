#' @export
#' @family Momentum Indicator
#'
#' @title Momentum
#' @templateVar .title Momentum
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun momentum
#' @templateVar .family Momentum Indicator
#' @templateVar .formula ~ close
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
#' @template returns
momentum <- function(
	x,
	cols,
	n = 10,
	na.bridge = FALSE,
	...
) {
	UseMethod("momentum")
}

#' @export
#' @usage NULL
#' @rdname momentum
#'
#' @aliases momentum
MOM <- momentum

#' @usage NULL
#' @aliases momentum
#'
#' @export
momentum.default <- function(
	x,
	cols,
	n = 10,
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
		C_impl_ta_MOM,
		## splice:call:start
		constructed_series[[1]],
		as.integer(n),
		## splice:call:end
		as.logical(na.bridge)
	)

	## readd rownames
	set_rownames(x, x_names)

	## return indicator
	x
}

#' @usage NULL
#' @aliases momentum
#'
#' @export
momentum.data.frame <- function(
	x,
	cols,
	n = 10,
	na.bridge = FALSE,
	...
) {
	map_dfr(
		momentum.default(
			x = x,
			cols = cols,
			n = n,
			na.bridge = na.bridge,
			...
		)
	)
}

#' @usage NULL
#' @aliases momentum
#'
#' @export
momentum.matrix <- function(
	x,
	cols,
	n = 10,
	na.bridge = FALSE,
	...
) {
	momentum.default(
		x = x,
		cols = cols,
		n = n,
		na.bridge = na.bridge,
		...
	)
}


#' @usage NULL
#' @aliases momentum
#'
#' @export
momentum.numeric <- function(
	x,
	cols,
	n = 10,
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
		C_impl_ta_MOM,
		## splice:numeric:start
		as.double(x),
		as.integer(n),
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
#' @aliases momentum
#'
#' @export
momentum.plotly <- function(
	x,
	cols,
	n = 10,
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
		default = ~close,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- momentum(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		n = n,
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
	name <- sprintf(
		"MOM(%d)",
		n
	)

	traces <- list(
		list(y = ~MOM)
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
				"Momentum"
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
#' @aliases momentum
#'
#' @export
momentum.ggplot <- function(
	x,
	cols,
	n = 10,
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
		default = ~close,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- momentum(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		n = n,
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
	name <- sprintf("MOM(%d)", n)
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
				"Momentum"
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
