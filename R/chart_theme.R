#' Chart themes
#'
#' Set the active chart color theme used by the package's chart rendering
#' functions.
#'
#' @details
#' Themes **mutate** the package-level theme state stored in `.chart_variables`.
#'
#' @return Invisibly returns `.chart_variables` after modification.
#' @family Chart Themes
#' @name chart_themes
NULL

## available themes
.theme_registry <- list(
	hawks_and_doves = list(
		## candle-colors
		bearish_body = "#A9A9A9",
		bearish_wick = "#8A8A8A",
		bearish_border = "#7A7A7A",
		bullish_body = "#4D4D4D",
		bullish_wick = "#505050",
		bullish_border = "#3D3D3D",

		## general-colors
		background_color = "#FFFFFF",
		foreground_color = "#333333",
		text_color = "#333333",

		## colorway
		colorway = c(
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
		),

		## grid
		gridcolor = "#E6E6E6"
	),

	payout = list(
		## candle-colors
		bearish_body = "#2F4F4F",
		bearish_wick = "#2F4F4F",
		bearish_border = "#2F4F4F",
		bullish_body = "#008080",
		bullish_wick = "#5F9EA0",
		bullish_border = "#5F9EA0",

		## general-colors
		background_color = "#1A1A1A",
		foreground_color = "#CFCFCF",
		text_color = "#CFCFCF",

		## colorway
		colorway = c(
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
		),

		## grid
		gridcolor = "#2B2B2B"
	),

	tp_slapped = list(
		## candle-colors
		bearish_body = "#e74c3c",
		bearish_wick = "#c0392b",
		bearish_border = "#c0392b",
		bullish_body = "#1abc9c",
		bullish_wick = "#16a085",
		bullish_border = "#16a085",

		## general-colors
		background_color = "#ecf0f1",
		foreground_color = "#2c3e50",
		text_color = "#2c3e50",

		## colorway
		colorway = c(
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
		),

		## grid
		gridcolor = "#D7DDE0"
	),

	trust_the_process = list(
		## candle-colors
		bearish_body = "#A9A9A9",
		bearish_wick = "#696969",
		bearish_border = "#B0B0B0",
		bullish_body = "#808080",
		bullish_wick = "#696969",
		bullish_border = "#707070",

		## general-colors
		background_color = "#F5F5F5",
		foreground_color = "#333333",
		text_color = "#333333",

		## colorway
		colorway = c(
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
		),

		## grid
		gridcolor = "#E6E6E6"
	)
)

.apply_chart_theme <- function(spec) {
	if (is.environment(.chart_variables)) {
		for (nm in names(spec)) {
			assign(nm, spec[[nm]], envir = .chart_variables)
		}
	} else {
		for (nm in names(spec)) {
			.chart_variables[[nm]] <- spec[[nm]]
		}
	}
	invisible(.chart_variables)
}

.make_theme_fn <- function(spec) {
	force(spec)
	function() .apply_chart_theme(spec)
}

#' Theme accessor
#'
#' Access theme setters via `$`.
#'
#' @details
#' Example: `set_theme$theme_tp_slapped()` or `set_theme()$theme_tp_slapped()`.
#'
#' @return Returns itself (so `set_theme()` is chainable with `$`).
#' @family Chart Themes
#' @export
set_theme <- local({
	f <- function() f
	class(f) <- c("chart_theme", class(f))
	f
})

#' @export
`$.chart_theme` <- function(x, name) {
	specs <- .theme_registry
	if (!nzchar(name) || is.null(specs[[name]])) {
		stop(
			"Unknown theme '",
			name,
			"'. Available: ",
			paste(names(specs), collapse = ", "),
			call. = FALSE
		)
	}
	.make_theme_fn(specs[[name]])
}

#' @importFrom utils .DollarNames
#' @export
.DollarNames.chart_theme <- function(x, pattern = "") {
	grep(pattern, names(.theme_registry), value = TRUE)
}
