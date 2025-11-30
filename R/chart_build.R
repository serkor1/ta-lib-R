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
build_plotly <- function(init, traces, name, data, ...) {
	UseMethod("build_plotly")
}

#' @export
build_plotly.plotly <- function(init, traces, name, data, ...) {
	if (missing(data)) {
		data <- get("constructed_indicator", parent.frame())
	}

	## default traces
	default_trace <- list(
		type = "scatter",
		mode = "lines",
		showlegend = FALSE,
		inherit = FALSE,
		data = data,
		x = ~idx
	)

	traces <- lapply(traces, function(tr) {
		utils::modifyList(default_trace, tr)
	})

	if (length(traces) > 1) {
		##
		element <- traces[[length(traces)]]
		element$showlegend <- TRUE
		element$visible <- "legendonly"
		element$name <- name
		traces[[length(traces) + 1]] <- element
	}

	## construct object
	Reduce(
		f = function(acc, tr) {
			do.call(plotly::add_trace, c(list(acc), tr))
		},
		x = traces,
		init = init
	)
}
