#' @title Build Plot
#'
#' @description
#' Placeholder
#'
#' @param init placeholder
#' @param traces placeholder
#' @param name placeholder
#'
#' @keywords internal
#' @returns
#' A <plotly>-object
#'
build_plotly <- function(init, traces, name, data, title = NULL, ...) {
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
	# data fallback
	if (missing(data)) {
		data <- get("constructed_indicator", parent.frame())
	}

	# default for non-line traces
	default_trace <- list(
		type = "scatter",
		mode = "lines",
		showlegend = TRUE,
		inherit = FALSE,
		data = data,
		x = ~idx
	)

	# identify plotly_line traces
	is_line <- vapply(traces, inherits, logical(1), "plotly_line")
	non_line <- which(!is_line)

	# apply defaults only to non-line traces
	if (length(non_line) > 0) {
		traces[non_line] <- lapply(
			traces[non_line],
			function(tr) utils::modifyList(default_trace, tr)
		)
	}

	n_tr <- length(traces)
	n_non <- length(non_line)

	if (n_non > 0) {
		if (n_tr > 1 && n_non > 1) {
			# add a dedicated legend entry
			legend_tr <- traces[[non_line[1]]]
			legend_tr$showlegend <- TRUE
			legend_tr$visible <- "legendonly"
			legend_tr$name <- name

			traces <- append(traces, list(legend_tr))
		} else {
			# just name the single relevant non-line trace
			traces[[non_line[1]]]$name <- name
		}
	}

	# build plotly object
	plotly_object <- Reduce(
		f = function(acc, tr) {
			do.call(plotly::add_trace, c(list(acc), tr))
		},
		x = traces,
		init = init
	)

	# decorate
	if (!is.null(title)) {
		plotly_object <- add_title(plotly_object, text = title)
	}

	# check for additional options
	if (!is.empty(decorators)) {
		plotly_object <- Reduce(
			f = function(p, f) f(p),
			x = decorators,
			init = plotly_object
		)
	}

	layout_axis(plotly_object, data$idx)
}
