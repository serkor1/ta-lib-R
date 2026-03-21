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
	default = list(
		## candle-colors
		bearish_body = "#4682B4",
		bearish_wick = "#4682B4",
		bearish_border = "#3B6A93",
		bullish_body = "#E0FFFF",
		bullish_wick = "#E0FFFF",
		bullish_border = "#C0D9D9",

		## general-colors
		background_color = "#141414",
		foreground_color = "#E0FFFF",
		text_color = "#E0FFFF",

		## colorway
		colorway = c(
			"#E0FFFF",
			"#B5F3FF",
			"#7DD3FC",
			"#5BC0EB",
			"#4682B4",
			"#2E86AB",
			"#00B3B8",
			"#44D7B6",
			"#C792EA",
			"#F6C177"
		),

		## gridcolor
		gridcolor = "#232A30",

		## threshold line color
		threshold_color = "#5A6270"
	),

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
		threshold_color = "#999999",

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
		threshold_color = "#9499A0",

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
		threshold_color = "#7f8c8d",

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
		threshold_color = "#999999",

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

#' Set or list chart themes
#'
#' Apply a chart color theme or list available themes.
#'
#' @details
#' Three usage patterns:
#' \describe{
#'  \item{`set_theme()`}{Lists available theme names.}
#'  \item{`set_theme("payout")`}{Applies a theme by name.}
#'  \item{`set_theme$payout`}{Applies a theme via `$` (supports tab-completion).}
#' }
#'
#' @param name Optional [character] theme name. If omitted, returns
#'  available theme names.
#' @param ... Named color overrides applied after the base theme
#'  (e.g., `background_color = "#000000"`).
#'
#' @return When called without arguments, a character vector of theme names.
#'  Otherwise, invisibly returns `.chart_variables` after modification.
#' @family Chart Themes
#' @export
set_theme <- local({
	f <- function(name, ...) {
		if (missing(name) && ...length() == 0L) {
			return(names(.theme_registry))
		}

		if (!missing(name)) {
			name <- match.arg(name, names(.theme_registry))
			.apply_chart_theme(.theme_registry[[name]])
		}

		overrides <- list(...)
		if (length(overrides) > 0L) {
			.apply_chart_theme(overrides)
		}

		invisible(.chart_variables)
	}
	class(f) <- c("chart_theme", class(f))
	f
})

#' @export
`$.chart_theme` <- function(x, name) {
	if (!nzchar(name) || is.null(.theme_registry[[name]])) {
		stop(
			"Unknown theme '",
			name,
			"'. Available: ",
			paste(names(.theme_registry), collapse = ", "),
			call. = FALSE
		)
	}
	.apply_chart_theme(.theme_registry[[name]])
}

#' @importFrom utils .DollarNames
#' @export
.DollarNames.chart_theme <- function(x, pattern = "") {
	grep(pattern, names(.theme_registry), value = TRUE)
}
