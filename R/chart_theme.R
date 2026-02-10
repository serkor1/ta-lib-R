#' Chart themes
#'
#' Set the active chart color theme used by the package's chart rendering
#' functions.
#'
#' @details
#' These functions **mutate** the package-level theme state stored in
#' `.chart_variables`. They are intended to be called before drawing charts.
#'
#' @section Fields set:
#' - Candles:
#'   - `bearish_body`, `bearish_wick`, `bearish_border`
#'   - `bullish_body`, `bullish_wick`, `bullish_border`
#' - General:
#'   - `background_color`, `foreground_color`, `text_color`
#' - Series:
#'   - `colorway` (character vector of hex colors; used for multi-trace/indicator series)
#' - Grid:
#'   - `gridcolor` (hex or rgba; used for axis grid lines)
#'
#' @return Invisibly returns `.chart_variables` after modification.
#' @family Chart Themes
#' @name chart_themes
#'
NULL

#' Hawks and Doves theme
#'
#' Neutral grayscale candles on a light background.
#'
#' @rdname chart_themes
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

	## colorways
	.chart_variables$colorway <- c(
		"#b8b0ac",
		"#5778a4",
		"#85b6b2",
		"#6a9f58",
		"#a87c9f",
		"#967662",
		"#e49444",
		"#d1615d",
		"#f1a2a9",
		"#e7ca60"
	)

	.chart_variables$gridcolor <- "#E6E6E6"
}

#' Payout theme
#'
#' Dark background theme with teal bullish candles.
#'
#' @rdname chart_themes
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

	## colorway
	.chart_variables$colorway <- c(
		"#008080",
		"#EF553B",
		"#636EFA",
		"#AB63FA",
		"#FFA15A",
		"#19D3F3",
		"#FF6692",
		"#B6E880",
		"#FF97FF",
		"#FECB52"
	)

	.chart_variables$gridcolor <- "#2B2B2B"
}

#' TP Slapped theme
#'
#' High-contrast red/green candles on a light background.
#'
#' @rdname chart_themes
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

	## colorway
	.chart_variables$colorway <- c(
		"#1abc9c",
		"#2ecc71",
		"#3498db",
		"#9b59b6",
		"#f1c40f",
		"#f39c12",
		"#e67e22",
		"#e74c3c",
		"#34495e",
		"#95a5a6"
	)

	.chart_variables$gridcolor <- "#D7DDE0"
}

#' @export
theme_trust_the_process <- function() {
	## candle-colors
	.chart_variables$bearish_body <- "#A9A9A9"
	.chart_variables$bearish_wick <- "#696969"
	.chart_variables$bearish_border <- "#B0B0B0"
	.chart_variables$bullish_body <- "#808080"
	.chart_variables$bullish_wick <- "#696969"
	.chart_variables$bullish_border <- "#707070"

	## general-colors
	.chart_variables$background_color <- "#F5F5F5"
	.chart_variables$foreground_color <- "#333333"
	.chart_variables$text_color <- "#333333"

	.chart_variables$colorway <- c(
		"#272E31",
		"#6C514D",
		"#5C6F5F",
		"#6E8785",
		"#756F6D",
		"#AF804B",
		"#B3B186",
		"#D9BDA5",
		"#E0C9A6",
		"#D16014"
	)

	.chart_variables$gridcolor <- "#E6E6E6"
}
