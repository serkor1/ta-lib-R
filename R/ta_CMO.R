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
		as.integer(n)
		## splice:call:end
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
	...
) {
	as.data.frame(
		chande_momentum_oscillator.default(
			x = x,
			cols = cols,
			n = n,
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
	...
) {
	as.matrix(
		chande_momentum_oscillator.default(
			x = x,
			cols = cols,
			n = n,
			...
		)
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
#' @aliases chande_momentum_oscillator
#'
#' @export
chande_momentum_oscillator.plotly <- function(
	x,
	cols,
	n = 10,
	## splice:optional-plotly:start
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

	## add conditional idx
	constructed_indicator[["idx"]] <- add_idx(
		constructed_series
	)

	## construct {plotly}-object
	## splice:plotly-assembly:start
	plotly_object <- subchart(
		data = constructed_indicator,
		y = ~CMO,
		type = "scatter",
		mode = "lines",
		showlegend = FALSE
	)

	plotly_object <- add_ribbons(
		plotly_object = plotly_object,
		data = constructed_indicator,
		x = ~idx,
		ymin = rep(-50, nrow(constructed_indicator)),
		ymax = rep(50, nrow(constructed_indicator)),
		alpha = 0.5,
		color = "lightgray",
		showlegend = FALSE,
		legendgroup = "cmo_area",
		name = "cmo_area",
		dash = "dot"
	)

	if (main_chart_exists()) {
		plotly_object <- add_title(
			x = plotly_object,
			text = sprintf(
				"Chande Momentum Indicator (%d)",
				n
			)
		)
	}

	.plotting_environment$sub <- c(
		.plotting_environment$sub,
		list(plotly_object)
	)
	## splice:plotly-assembly:end

	plotly_object
}
