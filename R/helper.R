## script: helper functions
## for the small repetitative tasks
##
## output values
to_title <- function(
	x
) {
	## remove underscores
	## if preset
	x <- gsub(pattern = "_", replacement = " ", x = x)
	gsub("\\b(.)", "\\U\\1", tolower(x), perl = TRUE)
}

rebuild_formula <- function(
	x,
	exclude = "idx"
) {
	if (!is.character(x)) {
		x <- names(x)
	}
	## this function removes
	## idx and rebuilds the passed
	## series as formulas
	idx <- grepl(
		pattern = exclude,
		x = x,
		ignore.case = TRUE
	)

	stats::reformulate(
		x[!idx]
	)
}

add_idx <- function(x) {
	## store idx
	idx <- .plotting_environment$idx$label

	if (!is.null(idx)) {
		idx[
			if (is.null(attributes(x)$subset)) {
				1:nrow(x)
			} else {
				attributes(x)$subset
			}
		]
	} else {
		1:nrow(x)
	}
}

modify_traces <- function(trace_list, ...) {
	lapply(
		trace_list,
		function(traces) {
			utils::modifyList(
				traces,
				list(...)
			)
		}
	)
}

plotly_line <- function(value, length, dash = TRUE) {
	## if 'length' is missing, infer the length
	## from parent.frame
	if (missing(length)) {
		length <- nrow(
			get("constructed_indicator", parent.frame())
		)
	}

	x <- list(
		y = rep(value, length),
		x = ~idx,
		mode = "lines",
		type = "scatter",
		line = list(
			color = layout_theme()$threshold_color,
			width = 0.5
		),
		inherit = FALSE,
		showlegend = FALSE,
		data = get("constructed_indicator", parent.frame())
	)

	if (dash) {
		x$line$dash <- "dot"
	}

	class(x) <- "plotly_line"
	x
}


plotly_init <- function(...) {
	plotly::plot_ly(
		data = get("constructed_indicator", parent.frame()),
		x = ~idx,
		...
	)
}

is.empty <- function(x) {
	UseMethod("is.empty")
}

#' @export
is.empty.default <- function(x) {
	missing(x)
}

#' @export
is.empty.list <- function(x) {
	length(x) == 0L
}

#' @export
is.empty.character <- function(x) {
	identical(x, character(0)) | grepl("^[[:space:]]*$", x)
}


label <- function(
	label,
	...
) {
	x <- c(...)
	if (!length(x)) {
		return(label)
	}

	paste0(
		label,
		" (",
		toString(sprintf("%g", x)),
		")"
	)
}


`%or%` <- function(x, y) {
	if (missing(x)) {
		y
	} else {
		x
	}
}
