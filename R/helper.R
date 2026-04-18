## script - helper functions
## shared utilities for charting and indicators

## ---- operators ----

## null-coalescing operator
## returns y when x is NULL
`%nn%` <- function(x, y) if (is.null(x)) y else x

## missing-value fallback operator
## returns y when x is missing - not NULL
`%or%` <- function(x, y) {
	if (missing(x)) {
		y
	} else {
		x
	}
}

## ---- text helpers ----

## convert snake_case to Title Case
## used for indicator chart titles
to_title <- function(
	x
) {
	## remove underscores
	x <- gsub(pattern = "_", replacement = " ", x = x)
	gsub("\\b(.)", "\\U\\1", tolower(x), perl = TRUE)
}

## format indicator parameter labels
## eg label RSI with n=14 becomes RSI (14)
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

## ---- formula helpers ----

## rebuild column formula from names
## removes idx and reconstructs as formula
rebuild_formula <- function(
	x,
	exclude = "idx"
) {
	if (!is.character(x)) {
		x <- names(x)
	}

	## filter out excluded columns
	idx <- grepl(
		pattern = exclude,
		x = x,
		ignore.case = TRUE
	)

	stats::reformulate(
		x[!idx]
	)
}

## ---- chart data helpers ----

## attach idx from the chart environment
## to the constructed indicator data
add_idx <- function(x) {
	## retrieve idx labels stored
	## by chart during initialization
	idx <- .chart_state()$idx$label

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

## apply named overrides to every trace
## in a list - used by band indicators
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

## ---- plotly helpers ----

## create a horizontal reference line
## for plotly subchart indicators
plotly_line <- function(value, length, dash = TRUE) {
	## if length is missing infer it
	## from the indicator data in the
	## calling environment
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
			color = .chart_variables$threshold_color,
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

## initialize a plotly object
## with indicator data from the calling environment
plotly_init <- function(...) {
	plotly::plot_ly(
		data = get("constructed_indicator", parent.frame()),
		x = ~idx,
		...
	)
}

## ---- ggplot2 helpers ----

## initialize an empty ggplot object
## used by generated indicator ggplot methods
ggplot_init <- function(...) {
	assert_ggplot2()
	ggplot2::ggplot()
}

## create a horizontal reference line
## for ggplot2 subchart indicators
ggplot_line <- function(value, length, dash = TRUE) {
	x <- list(
		value = value,
		dash = dash
	)
	class(x) <- "ggplot_line"
	x
}

## ---- generic helpers ----

## check if an object is empty
## S3 generic with methods for list and character
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
