#' Chart Themes
#'
#' @description
#' The charting system ships with a set of built-in color themes inspired by
#' [chartthemes.com](https://chartthemes.com/). Each theme controls candle
#' colors, background, text, grid lines, and a 10-color palette (colorway)
#' used to distinguish indicator lines.
#'
#' Use [set_theme()] to apply or list themes.
#'
#' @details
#'
#' ## Available Themes
#'
#' \describe{
#'   \item{`default`}{A dark theme with cyan and steel-blue tones. Light
#'     (`#E0FFFF`) bullish candles on a near-black (`#141414`) background
#'     with a cool blue (`#4682B4`) bearish candle. The colorway spans
#'     icy blues through teal and soft purple.}
#'   \item{`hawks_and_doves`}{A light, grayscale theme with a white background.
#'     Candles use shades of gray, making it suitable for print or
#'     presentations where color is secondary. The colorway uses muted,
#'     accessible tones.}
#'   \item{`payout`}{A dark teal theme on a near-black (`#1A1A1A`) background.
#'     Bullish candles are teal (`#008080`), bearish candles are dark slate
#'     (`#2F4F4F`). The colorway follows the default Plotly palette.}
#'   \item{`tp_slapped`}{A bright theme on a light gray (`#ECF0F1`)
#'     background. Red (`#E74C3C`) bearish and teal (`#1ABC9C`) bullish
#'     candles provide strong visual contrast. The colorway uses vivid,
#'     saturated colors.}
#'   \item{`trust_the_process`}{A subtle, earth-toned theme on a light gray
#'     (`#F5F5F5`) background. Both bull and bear candles use shades of gray,
#'     keeping the focus on indicator lines. The colorway uses muted natural
#'     tones.}
#'   \item{`bloomberg_terminal`}{A dark theme on a near-black (`#0E1017`)
#'     background with orange (`#FF8F40`) bullish and neutral-gray
#'     (`#BBB9B2`) bearish candles. Inspired by the Bloomberg Terminal
#'     interface. Colorblind-friendly (see below).}
#'   \item{`limit_up`}{A dark monochrome theme on a near-black (`#121212`)
#'     background. Candles use only luminance to encode direction (light-gray
#'     bullish vs dark-gray bearish). Colorblind-friendly (see below).}
#'   \item{`bid_n_ask`}{A light theme on an azure (`#F0FFFF`) background
#'     with steel-blue (`#4682B4`) bullish and tomato-red (`#FF6347`)
#'     bearish candles. The classic blue-vs-red trading pair.
#'     Colorblind-friendly (see below).}
#' }
#'
#' ## Colorblind-Friendly Themes
#'
#' The following themes encode bull/bear direction in ways that remain
#' distinguishable under the most common color-vision deficiencies. The
#' colorways for `bloomberg_terminal`, `limit_up`, and `bid_n_ask` are
#' derived from the Okabe & Ito (2008) qualitative palette, the de-facto
#' standard for accessible scientific visualization.
#'
#' \describe{
#'   \item{`limit_up`, `hawks_and_doves`, `trust_the_process`}{Encode
#'     direction with luminance only. Safe under deuteranopia, protanopia,
#'     tritanopia, and full achromatopsia.}
#'   \item{`bloomberg_terminal`}{Orange + neutral gray. Safe under all
#'     three CVD types thanks to Okabe-Ito-style hue separation.}
#'   \item{`default`, `payout`}{Cyan/teal + blue or dark slate. Safe under
#'     all three CVD types — the color pair sits inside the blue-yellow
#'     axis that CVD users perceive normally.}
#'   \item{`bid_n_ask`}{Blue + red. Safe under deuteranopia and
#'     protanopia (the most common forms, affecting ~8% of males); the
#'     pair separates more weakly under tritanopia.}
#' }
#'
#' `tp_slapped` is the only built-in that uses a teal/red pair adjacent to
#' the red-green CVD axis; prefer the themes above when accessibility
#' matters.
#'
#' ## Theme Properties
#'
#' Each theme sets the following color properties:
#'
#' \describe{
#'   \item{Candle colors}{`bearish_body`, `bearish_wick`, `bearish_border`,
#'     `bullish_body`, `bullish_wick`, `bullish_border`}
#'   \item{General colors}{`background_color`, `foreground_color` (axes and
#'     borders), `text_color`}
#'   \item{Grid and reference}{`gridcolor`, `threshold_color` (horizontal
#'     reference lines such as overbought/oversold levels)}
#'   \item{Colorway}{A vector of 10 colors cycled through for indicator
#'     lines and legends}
#' }
#'
#' Any of these properties can be individually overridden via the `...`
#' argument to [set_theme()].
#'
#' @references
#' Okabe, M. & Ito, K. (2008). *Color Universal Design (CUD): How to make
#' figures and presentations that are friendly to colorblind people.*
#' \url{https://jfly.uni-koeln.de/color/}
#'
#' @example man/examples/set_theme.R
#'
#' @family Charting
#' @name chart_themes
NULL

## ---- theme registry ----

## available themes - each theme defines
## candle colors - background - text and colorway
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
	),

	## ---- colorblind-friendly themes ----
	## three themes designed to remain distinguishable under deuteranopia,
	## protanopia, and tritanopia. Colorways use the Okabe-Ito qualitative
	## palette (Okabe & Ito, 2008) reordered to suit each background.

	bloomberg_terminal = list(
		## candle-colors
		## orange + neutral gray - distinguishable under all CVD types
		bearish_body = "#BBB9B2",
		bearish_wick = "#8F5125",
		bearish_border = "#BBB9B2",
		bullish_body = "#FF8F40",
		bullish_wick = "#8F5125",
		bullish_border = "#FF8F40",

		## general-colors
		background_color = "#0E1017",
		foreground_color = "#FFFFFF",
		text_color = "#FFFFFF",
		threshold_color = "#5A6168",

		## colorway - Okabe-Ito for dark backgrounds
		colorway = c(
			"#E69F00",
			"#56B4E9",
			"#F0E442",
			"#009E73",
			"#0072B2",
			"#D55E00",
			"#CC79A7",
			"#FFFFFF",
			"#BBBBBB",
			"#888888"
		),

		## grid
		gridcolor = "#1E2128"
	),

	limit_up = list(
		## candle-colors
		## pure luminance contrast - safe under all CVD types
		## including full achromatopsia
		bearish_body = "#5A5A5A",
		bearish_wick = "#4A4A4A",
		bearish_border = "#3F3F3F",
		bullish_body = "#B0B0B0",
		bullish_wick = "#A0A0A0",
		bullish_border = "#D0D0D0",

		## general-colors
		background_color = "#121212",
		foreground_color = "#E0E0E0",
		text_color = "#E0E0E0",
		threshold_color = "#7A7A7A",

		## colorway - Okabe-Ito for dark monochrome backgrounds
		colorway = c(
			"#56B4E9",
			"#E69F00",
			"#009E73",
			"#F0E442",
			"#CC79A7",
			"#0072B2",
			"#D55E00",
			"#FFFFFF",
			"#BBBBBB",
			"#888888"
		),

		## grid
		gridcolor = "#1E1E1E"
	),

	bid_n_ask = list(
		## candle-colors
		## blue + red - distinguishable under deuteranopia and
		## protanopia, weaker under tritanopia
		bearish_body = "#FF6347",
		bearish_wick = "#CD5C5C",
		bearish_border = "#E03D00",
		bullish_body = "#4682B4",
		bullish_wick = "#1E90FF",
		bullish_border = "#4169E1",

		## general-colors
		background_color = "#F0FFFF",
		foreground_color = "#2F4F4F",
		text_color = "#2F4F4F",
		threshold_color = "#7A8C99",

		## colorway - Okabe-Ito for light backgrounds
		colorway = c(
			"#0072B2",
			"#D55E00",
			"#009E73",
			"#CC79A7",
			"#E69F00",
			"#56B4E9",
			"#F0E442",
			"#000000",
			"#666666",
			"#AAAAAA"
		),

		## grid
		gridcolor = "#D6E6F2"
	)
)

## ---- theme application ----

## apply a theme specification to the
## chart variables environment
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
	invisible(NULL)
}

#' Set or List Chart Themes
#'
#' @description
#' Apply a named color theme to the charting system, override individual
#' theme properties, or list all available theme names. The themes are
#' inspired by [chartthemes.com](https://chartthemes.com/).
#'
#' Theme changes take effect immediately and apply to all subsequent
#' [chart()] and [indicator()] calls.
#'
#' @details
#' `set_theme` supports three usage patterns:
#'
#' \describe{
#'  \item{`set_theme()`}{Returns a character vector of available theme names.}
#'  \item{`set_theme("payout")`}{Applies the named theme.}
#'  \item{`set_theme$payout`}{Applies the named theme via `$` syntax (supports
#'    tab-completion in interactive sessions).}
#' }
#'
#' Themes can be combined with individual color overrides. When both `name`
#' and `...` are provided, the base theme is applied first, then the
#' overrides are applied on top:
#'
#' ```r
#' # Apply "payout" but with a custom background
#' set_theme("payout", background_color = "#000000")
#' ```
#'
#' It is also possible to override individual properties without selecting a
#' theme:
#'
#' ```r
#' # Change only the bearish candle color
#' set_theme(bearish_body = "#FF0000")
#' ```
#'
#' See [chart_themes] for a full description of all available themes and
#' their color properties.
#'
#' @param name An optional [character] string matching one of the available
#'   theme names. Partial matching is supported. If omitted (and no `...`
#'   overrides are given), returns the available theme names instead.
#' @param ... Named color overrides applied after the base theme. Valid names
#'   include any theme property: `bearish_body`, `bearish_wick`,
#'   `bearish_border`, `bullish_body`, `bullish_wick`, `bullish_border`,
#'   `background_color`, `foreground_color`, `text_color`, `gridcolor`,
#'   `threshold_color`, and `colorway` (a character vector of up to 10
#'   colors).
#'
#' @returns
#' When called without arguments, a [character] vector of available theme
#' names. Otherwise, invisibly returns `NULL`; the theme is applied as a
#' side effect to the internal chart-variables state.
#'
#' @seealso [chart_themes] for descriptions of each theme, [chart()] for
#'   creating charts.
#'
#' @example man/examples/set_theme.R
#'
#' @family Charting
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

		invisible(NULL)
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
