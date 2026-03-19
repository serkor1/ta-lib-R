#' @export
#' @family Momentum Indicator
#'
#' @title Chande Momentum Oscillator
#' @templateVar .title Chande Momentum Oscillator
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun chande_momentum_oscillator
#' @templateVar .family Momentum Indicator
#' @templateVar .formula ~ close
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
#' @template returns
chande_momentum_oscillator <- function(
	x,
	cols,
	n = 10,
	na.rm = FALSE,
	...
) {
	UseMethod("chande_momentum_oscillator")
}

#' @export
#' @usage NULL
#' @rdname chande_momentum_oscillator
#'
#' @aliases chande_momentum_oscillator
CMO <- chande_momentum_oscillator

#' @usage NULL
#' @aliases chande_momentum_oscillator
#'
#' @export
chande_momentum_oscillator.default <- function(
	x,
	cols,
	n = 10,
	na.rm = FALSE,
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
		"impl_ta_CMO",
		## splice:call:start
		constructed_series[[1]],
		as.integer(n),
		## splice:call:end
		as.logical(na.rm)
	)

	## readd rownames
	set_rownames(x, x_names)

	## return indicator
	x
}

#' @usage NULL
#' @aliases chande_momentum_oscillator
#'
#' @export
chande_momentum_oscillator.data.frame <- function(
	x,
	cols,
	n = 10,
	na.rm = FALSE,
	...
) {
	map_dfr(
		chande_momentum_oscillator.default(
			x = x,
			cols = cols,
			n = n,
			na.rm = na.rm,
			...
		)
	)
}

#' @usage NULL
#' @aliases chande_momentum_oscillator
#'
#' @export
chande_momentum_oscillator.matrix <- function(
	x,
	cols,
	n = 10,
	na.rm = FALSE,
	...
) {
	chande_momentum_oscillator.default(
		x = x,
		cols = cols,
		n = n,
		na.rm = na.rm,
		...
	)
}


#' @usage NULL
#' @aliases chande_momentum_oscillator
#'
#' @export
chande_momentum_oscillator.numeric <- function(
	x,
	cols,
	n = 10,
	na.rm = FALSE,
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
		"impl_ta_CMO",
		## splice:numeric:start
		as.double(x),
		as.integer(n),
		## splice:numeric:end
		as.logical(na.rm)
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
#' @aliases chande_momentum_oscillator
#'
#' @export
chande_momentum_oscillator.plotly <- function(
	x,
	cols,
	n = 10,
	## splice:optional-plotly:start
	lower_bound = -50,
	upper_bound = 50,
	## splice:optional-plotly:end
	na.rm = FALSE,
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
		default = ~close,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- chande_momentum_oscillator(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		n = n
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

	name <- sprintf("CMO(%d)", n)

	decorators <- list(
		function(p) add_limit(p, y_range = c(-100, 100))
	)

	traces <- list(
		plotly_line(lower_bound, nrow(constructed_indicator)),
		plotly_line(upper_bound, nrow(constructed_indicator)),
		list(
			y = ~CMO,
			name = "CMO",
			legendgroup = name,
			legendgrouptitle = list(
				text = name
			)
		)
	)
	## splice:plotly-assembly:end

	plotly_object <- add_last_value(
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
				"Chande Momentum Oscillator"
			} else {
				title
			}
		),
		data = constructed_indicator[, values_to_extract, drop = FALSE],
		values_to_extract = values_to_extract
	)

	.charting_environment$sub <- c(
		.charting_environment$sub,
		list(plotly_object)
	)

	plotly_object
}
