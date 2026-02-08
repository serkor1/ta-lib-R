## chart themes
##
##
##
##
##
#' @export
theme_hawks_and_doves <- function() {
	## candle-colors
	.chart_variables$bearish_body <- "#A9A9A9"
	.chart_variables$bearish_wick <- "#8A8A8A"
	.chart_variables$bearish_border <- "#7A7A7A"
	.chart_variables$bullish_body <- "#4D4D4D"
	.chart_variables$bullish_wick <- "#505050"
	.chart_variables$bullish_border <- "#3D3D3D"

	## general-colors
	.chart_variables$background_color <- "#FFFFFF"
	.chart_variables$foreground_color <- "#333333"
	.chart_variables$text_color <- "#333333"
}

#' @export
theme_payout <- function() {
	## candle-colors
	.chart_variables$bearish_body <- "#2F4F4F"
	.chart_variables$bearish_wick <- "#2F4F4F"
	.chart_variables$bearish_border <- "#2F4F4F"
	.chart_variables$bullish_body <- "#008080"
	.chart_variables$bullish_wick <- "#5F9EA0"
	.chart_variables$bullish_border <- "#5F9EA0"

	## general-colors
	.chart_variables$background_color <- "#1A1A1A"
	.chart_variables$foreground_color <- "#CFCFCF"
	.chart_variables$text_color <- "#CFCFCF"
}

#' @export
theme_tp_slapped <- function() {
	## candle-colors
	.chart_variables$bearish_body <- "#e74c3c"
	.chart_variables$bearish_wick <- "#c0392b"
	.chart_variables$bearish_border <- "#c0392b"
	.chart_variables$bullish_body <- "#1abc9c"
	.chart_variables$bullish_wick <- "#16a085"
	.chart_variables$bullish_border <- "#16a085"

	## general-colors
	.chart_variables$background_color <- "#ecf0f1"
	.chart_variables$foreground_color <- "#2c3e50"
	.chart_variables$text_color <- "#2c3e50"
}
