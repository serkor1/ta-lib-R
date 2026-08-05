## script: hexSticker
## author: Serkan Korkmaz
## objective: Generate a hex sticker
## with candlesticks and moving averages
##
## set clean to TRUE for deleting auxillary files
## run this code in the terminal to replace
## the log:
clean <- TRUE

## file destinations
raw_file <- "talib-hex-raw.svg"
final_file <- "talib-hex.svg"

## common colors and fonts
## across the sticker
bg <- "#101A24"
accent <- "#6FBFBF"
up <- "#65a479"
down <- "#d5695d"
ink <- "#D8DEE3"

## render text at the same dpi the sticker is saved at
dpi <- 1200
sysfonts::font_add_google("JetBrains Mono", "jbmono")
showtext::showtext_auto()
showtext::showtext_opts(dpi = dpi)

## construct OHLC
## series
set.seed(1903)
n <- 18
x <- seq_len(n)
open <- cumsum(rnorm(n, 0, 1)) + 100
close <- open + rnorm(n, 0, 1)
high <- pmax(open, close) + runif(n, 0.4, 1.1)
low <- pmin(open, close) - runif(n, 0.4, 1.1)
OHLC <- data.frame(x, open, close, high, low, up = close >= open)

## construct moving averages
## long/short
ma_short <- stats::filter(close, rep(1 / 3, 3), sides = 1)
ma_long <- stats::filter(close, rep(1 / 6, 6), sides = 1)

## add grids to the
## plot for shabang
## effect
y_rng <- range(OHLC$low, OHLC$high)
y_major <- pretty(y_rng, n = 5)
y_minor <- setdiff(pretty(y_rng, n = 11), y_major)

x_major <- pretty(range(OHLC$x), n = 6)
x_minor <- setdiff(pretty(range(OHLC$x), n = 13), x_major)

grid_major_col <- "#1A2A38"
grid_minor_col <- "#14222D"


## construct plot
## with {ggplot}
w <- 0.34

p_candles <- ggplot2::ggplot(OHLC, ggplot2::aes(x = x)) +
	ggplot2::geom_hline(
		yintercept = y_major,
		color = grid_major_col,
		linewidth = 0.28,
		alpha = 0.55
	) +
	ggplot2::geom_hline(
		yintercept = y_minor,
		color = grid_minor_col,
		linewidth = 0.22,
		alpha = 0.35
	) +
	ggplot2::geom_vline(
		xintercept = x_major,
		color = grid_major_col,
		linewidth = 0.26,
		alpha = 0.55
	) +
	ggplot2::geom_vline(
		xintercept = x_minor,
		color = grid_minor_col,
		linewidth = 0.20,
		alpha = 0.35
	) +
	## candle wicks
	ggplot2::geom_segment(
		ggplot2::aes(xend = x, y = low, yend = high),
		linewidth = 0.45,
		color = "#B3C2D1"
	) +
	## candle body
	ggplot2::geom_rect(
		ggplot2::aes(
			xmin = x - w,
			xmax = x + w,
			ymin = pmin(open, close),
			ymax = pmax(open, close),
			fill = up,
			color = up
		),
		linewidth = 0.25
	) +
	## moving averages
	ggplot2::geom_line(
		ggplot2::aes(y = ma_long),
		color = "#00BFA6",
		linewidth = 0.8,
		na.rm = TRUE
	) +
	ggplot2::geom_line(
		ggplot2::aes(y = ma_short),
		color = accent,
		linewidth = 1.0,
		na.rm = TRUE
	) +
	ggplot2::scale_fill_manual(values = c(`TRUE` = up, `FALSE` = down)) +
	ggplot2::scale_color_manual(values = c(`TRUE` = up, `FALSE` = down)) +
	ggplot2::coord_cartesian(expand = FALSE) +
	ggplot2::theme_void() +
	hexSticker::theme_transparent() +
	ggplot2::theme(legend.position = "none")

## construct stricker and
## store locally
hexSticker::sticker(
	p_candles,
	package = "{talib}",
	p_family = "jbmono",
	p_size = 3,
	p_color = grid_minor_col,
	p_x = 0.503,
	p_y = 1.313,
	s_x = 1,
	s_y = 1,
	s_width = 2,
	s_height = 2,
	h_fill = bg,
	h_color = accent,
	h_size = 1,
	url = "",
	u_color = grid_major_col,
	u_size = 3.5,
	u_x = 0.4,
	u_y = 1.6,
	u_angle = 30,
	filename = raw_file,
	dpi = dpi,
	# device = ragg::agg_png,
	bg = "transparent",
	white_around_sticker = FALSE
)

## crop everything outside the hex by clipping the SVG to a
## hexagon-shaped <clipPath>.
svg <- readLines(raw_file, warn = FALSE)

poly_line <- grep("<polygon ", svg, fixed = TRUE)[1]
if (is.na(poly_line)) {
	stop("no <polygon> found in ", raw_file, " -- cannot locate the hexagon")
}
hex_pts <- trimws(sub(".*points='([^']*)'.*", "\\1", svg[poly_line]))

clip_def <- sprintf(
	"<defs><clipPath id='hexclip'><polygon points='%s'/></clipPath></defs>",
	hex_pts
)

## inject the clip definition next to the <svg> tag and clip the
## svglite drawing group to the hexagon
svg_line <- grep("<svg ", svg, fixed = TRUE)[1]

## crop the canvas to the hexagon's bounding box so the
## transparent margin is symmetric on all sides
pts <- do.call(
	rbind,
	lapply(strsplit(strsplit(hex_pts, " +")[[1]], ","), as.numeric)
)
hex_w <- diff(range(pts[, 1]))
hex_h <- diff(range(pts[, 2]))
svg[svg_line] <- sub(
	"width='[^']*' height='[^']*' viewBox='[^']*'",
	sprintf(
		"width='%.2fpt' height='%.2fpt' viewBox='%.2f %.2f %.2f %.2f'",
		hex_w,
		hex_h,
		min(pts[, 1]),
		min(pts[, 2]),
		hex_w,
		hex_h
	),
	svg[svg_line]
)

svg[svg_line] <- paste0(svg[svg_line], clip_def)
svg <- sub(
	"<g class='svglite'>",
	"<g class='svglite' clip-path='url(#hexclip)'>",
	svg,
	fixed = TRUE
)

writeLines(svg, final_file)
usethis::use_logo(final_file, geometry = "1980x1200")

if (clean) {
	base::unlink(raw_file, force = TRUE)
	base::unlink(final_file, force = TRUE)
}
