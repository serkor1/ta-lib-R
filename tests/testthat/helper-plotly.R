## script: <plotly>-helper
## description:
##
##		The financial charts in {talib} has a few common
##      elements that is expected to be present by default.
##      This script builds helpers to identify these.
##
##		Common for *all* charts with indicators
## 		- <character>: OHLC prices in Annotations
##      - <character>: Legends, and Legend Title
##      - <character>: Names that are not called "Trace"
##
##		Common for *all* subcharts
##		- <character>: Title
##
## objective:
##
##

## identify and count titles
extract_annotations <- function(x) {
	x$x$layout$annotations
}

extract_data <- function(x) {
	x$x$data
}


plotly_annotations <- function(x) {
	sapply(
		extract_annotations(x),
		function(x) {
			x$text
		}
	)
}

plotly_names <- function(x) {
	do.call(
		c,
		sapply(
			extract_data(x),
			function(x) {
				as.character(x$name)
			}
		)
	)
}

plotly_legend_groups <- function(x) {
	do.call(
		c,
		sapply(
			extract_data(x),
			function(x) {
				x$legendgroup
			}
		)
	)
}

plotly_legend_title <- function(x) {
	do.call(
		c,
		sapply(
			extract_data(x),
			function(x) {
				x$legendgrouptitle$text
			}
		)
	)
}
