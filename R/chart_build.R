#' @title build_plotly
#'
#' @description
#' A high-level <plotly> builder for the <plotly>-methods.
#'
#' @param init A <plotly>-object to be built, or built upon.
#' @param traces A nested <[list]> of <plotly> arguments.
#' @param decorators A <[list]> of functions that decorates the <plotly>-objecty. Can be an empty <[list]>.
#' @param name A <[character]>-vector of [length] 1. The name of the indicator; relevant mainly for univariate series.
#' @param data A <[data.frame]> with the calculated indicator.
#' @param title A <[character]>-vector of [length] 1. This adds a title to the subchart.
#'
#' @returns
#' A <plotly>-object
#'
#' @keywords internal
build_plotly <- function(
	init,
	traces,
	decorators = list(),
	name,
	data,
	title = NULL,
	...
) {
	UseMethod("build_plotly")
}

#' @export
build_plotly.plotly <- function(
	init,
	traces,
	decorators = list(),
	name,
	data,
	title = NULL,
	...
) {
	## added to avoid
	## having to go back and
	## recode everything
	if (missing(data)) {
		data <- get(
			"constructed_indicator",
			parent.frame()
		)
	}

	## replace missing names
	## with title
	if (missing(name) | is.null(name)) {
		name <- title
	}

	## filter
	if (!is.null(attr(data, "lookback", TRUE))) {
		data <- data[-(1:attr(data, "lookback", TRUE)), ]
	}

	# default for non-line traces
	default_trace <- list(
		type = "scatter",
		mode = "lines",
		showlegend = TRUE,
		inherit = FALSE,

		## name and legendgroup
		## has to be unique
		name = name,
		legendgroup = name,
		legendgrouptitle = list(
			text = if (missing(title)) {
				name
			} else {
				title
			}
		),
		data = data,
		x = ~idx
	)

	# identify plotly_line traces
	is_line <- vapply(
		traces,
		inherits,
		logical(1),
		"plotly_line"
	)

	non_line <- which(!is_line)

	# apply defaults only to non-line traces
	if (length(non_line) > 0) {
		traces[non_line] <- lapply(
			traces[non_line],
			function(tr) {
				utils::modifyList(
					default_trace,
					tr,
					keep.null = TRUE
				)
			}
		)
	}

	n_tr <- length(traces)
	n_non <- length(non_line)

	# build plotly object
	plotly_object <- Reduce(
		f = function(acc, tr) {
			do.call(
				plotly::add_trace,
				c(list(acc), tr)
			)
		},
		x = traces,
		init = init
	)

	# decorate
	if (!is.null(title)) {
		plotly_object <- add_title(
			plotly_object,
			text = title
		)
	}

	# check for additional options
	if (!is.empty(decorators)) {
		plotly_object <- Reduce(
			f = function(p, f) f(p),
			x = decorators,
			init = plotly_object
		)
	}

	## common decorators
	fns <- list(
		function(p) layout_background(p),
		function(p) layout_axis(p, data$idx)
	)

	Reduce(
		f = function(p, f) f(p),
		x = fns,
		init = plotly_object
	)
}
