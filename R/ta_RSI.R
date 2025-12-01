#' @export
#' @family Momentum Indicator
#'
#' @title Relative Strength Index
#' @templateVar .title Relative Strength Index
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun relative_strength_index
#' @templateVar .family Momentum Indicator
#' @templateVar .formula ~close
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
#' @template returns
relative_strength_index <- function(
	x,
	cols,
	n = 10,
	...
) {
	UseMethod("relative_strength_index")
}

#' @export
#' @usage NULL
#' @rdname relative_strength_index
#'
#' @aliases relative_strength_index
RSI <- relative_strength_index

#' @usage NULL
#' @aliases relative_strength_index
#'
#' @export
relative_strength_index.default <- function(
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
		"impl_ta_RSI",
		## splice:call:start
		constructed_series[[1]],
		as.integer(n)
		## splice:call:end
	)

	## readd rownames
	set_rownames(x, x_names)

	## return indicator
	x
}

#' @usage NULL
#' @aliases relative_strength_index
#'
#' @export
relative_strength_index.data.frame <- function(
	x,
	cols,
	n = 10,
	...
) {
	map_dfr(
		relative_strength_index.default(
			x = x,
			cols = cols,
			n = n,
			...
		)
	)
}

#' @usage NULL
#' @aliases relative_strength_index
#'
#' @export
relative_strength_index.matrix <- function(
	x,
	cols,
	n = 10,
	...
) {
	relative_strength_index.default(
		x = x,
		cols = cols,
		n = n,
		...
	)
}

#' @usage NULL
#' @aliases relative_strength_index
#'
#' @export
relative_strength_index.numeric <- function(
	x,
	cols,
	n = 10,
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
		"impl_ta_RSI",
		## splice:numeric:start
		as.double(x),
		as.integer(n)
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
#' @aliases relative_strength_index
#'
#' @export
relative_strength_index.plotly <- function(
	x,
	cols,
	n = 10,
	## splice:optional-plotly:start
	lower_bound = 20,
	upper_bound = 80,
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
		default = ~close,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- relative_strength_index(
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
		"RSI(%d)",
		n
	)

	traces <- list(
		plotly_line(lower_bound),
		plotly_line(upper_bound),
		list(y = ~RSI)
	)
	## splice:plotly-assembly:end

	plotly_object <- build_plotly(
		init = plotly_init(),
		traces = traces,
		name = name,
		data = constructed_indicator,
		title = if (missing(title)) {
			"Relative Strength Index"
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
