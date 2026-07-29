## script: social-preview
## author: Serkan Korkmaz
## objective: Generate the GitHub social preview (1280x640)
## using the same color palette, synthetic data, and ggplot
## scaffolding as dev/hexSticker.R so the preview shares the
## hex sticker's brand identity.
##
## Output: man/figures/social-preview.png
##         man/figures/social-preview.svg
##
## Usage:
##   Rscript dev/social-preview.R

out_file <- "man/figures/social-preview.png"
out_file_svg <- "man/figures/social-preview.svg"

## ---- colors (mirroring dev/hexSticker.R) ----
bg <- "#101A24"
accent <- "#6FBFBF"
up <- "#65a479"
down <- "#d5695d"
ink <- "#D8DEE3"

ma_short_col <- accent
ma_long_col <- "#00BFA6"
wick_col <- "#B3C2D1"

grid_major_col <- "#1A2A38"
grid_minor_col <- "#14222D"

## ---- synthetic OHLC series ----
## same seed and generator as dev/hexSticker.R
set.seed(1903)
n <- 18
x <- seq_len(n)
open <- cumsum(rnorm(n, 0, 1)) + 100
close <- open + rnorm(n, 0, 1)
high <- pmax(open, close) + runif(n, 0.4, 1.1)
low <- pmin(open, close) - runif(n, 0.4, 1.1)
OHLC <- data.frame(x, open, close, high, low, up = close >= open)

## ---- moving averages (long / short) ----
ma_short <- stats::filter(close, rep(1 / 3, 3), sides = 1)
ma_long <- stats::filter(close, rep(1 / 6, 6), sides = 1)

## ---- gridlines ----
y_rng <- range(OHLC$low, OHLC$high)
y_major <- pretty(y_rng, n = 5)
y_minor <- setdiff(pretty(y_rng, n = 11), y_major)

x_major <- pretty(range(OHLC$x), n = 6)
x_minor <- setdiff(pretty(range(OHLC$x), n = 13), x_major)

## ---- plot ----
w <- 0.34

p <- ggplot2::ggplot(OHLC, ggplot2::aes(x = x)) +
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
		color = wick_col
	) +
	## candle bodies
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
		color = ma_long_col,
		linewidth = 0.8,
		na.rm = TRUE
	) +
	ggplot2::geom_line(
		ggplot2::aes(y = ma_short),
		color = ma_short_col,
		linewidth = 1.0,
		na.rm = TRUE
	) +
	ggplot2::scale_fill_manual(values = c(`TRUE` = up, `FALSE` = down)) +
	ggplot2::scale_color_manual(values = c(`TRUE` = up, `FALSE` = down)) +
	## symmetric horizontal padding so the first and last candle bodies
	## (which extend +/- w around their x position) are fully visible
	ggplot2::coord_cartesian(
		xlim = c(1 - w - 0.15, n + w + 0.15),
		expand = FALSE
	) +
	ggplot2::theme_void() +
	ggplot2::theme(
		legend.position = "none",
		plot.background = ggplot2::element_rect(fill = bg, color = NA),
		panel.background = ggplot2::element_rect(fill = bg, color = NA)
	)

## ---- save (1280 x 640) ----
ggplot2::ggsave(
	filename = out_file,
	plot = p,
	width = 1280,
	height = 640,
	units = "px",
	dpi = 132,
	device = ragg::agg_png,
	bg = bg
)

ggplot2::ggsave(
	filename = out_file_svg,
	plot = p,
	width = 1280,
	height = 640,
	units = "px",
	dpi = 132,
	device = svglite::svglite,
	bg = bg
)

## svglite declares the canvas in physical pt; rewrite it to
## 1280x640 (CSS px) so the SVG reports the same dimensions as
## the PNG -- the viewBox is kept, so the drawing is unchanged
svg <- readLines(out_file_svg, warn = FALSE)
svg <- sub(
	"width='[^']*' height='[^']*' (viewBox=)",
	"width='1280' height='640' \\1",
	svg
)
writeLines(svg, out_file_svg)
