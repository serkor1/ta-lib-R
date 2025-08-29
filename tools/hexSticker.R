## script: hexSticker
## author: Serkan Korkmaz
## objective: Generate a hex sticker
## with candlesticks and moving averages
##
## set clean to TRUE for deleting auxillary files
## run this code in the terminal to replace
## the log:
##
## Rscript -e "usethis::use_logo('talib-hex.png')"
clean <- TRUE

## file destinations
raw_file <- "talib-hex-raw.png"
final_file <- "talib-hex.png"
mask_file <- "talib-hex-mask.png"

## common colors and fonts
## across the sticker
bg <- "#101A24"
accent <- "#6FBFBF"
up <- "#65a479"
down <- "#d5695d"
ink <- "#D8DEE3"

sysfonts::font_add_google("JetBrains Mono", "jbmono")
showtext::showtext_auto()

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
	package = "",
	p_family = "jbmono",
	p_size = 33,
	p_color = ink,
	p_y = 1.44,
	s_x = 1,
	s_y = 1,
	s_width = 2,
	s_height = 2,
	h_fill = bg,
	h_color = accent,
	h_size = 1,
	url = "{talib}",
	u_color = accent,
	u_size = 33,
	u_x = 0.4,
	u_y = 1.5,
	u_angle = 30,
	filename = raw_file,
	dpi = 600,
	device = ragg::agg_png,
	bg = "transparent",
	white_around_sticker = FALSE
)

## construct an additional
## hexsticker to crop figures outside
## the hex
p_blank <- ggplot2::ggplot() +
	ggplot2::theme_void() +
	hexSticker::theme_transparent()

hexSticker::sticker(
	p_blank,
	package = "",
	p_size = 1,
	p_color = "white",
	s_x = 1,
	s_y = 1,
	s_width = 1,
	s_height = 1,
	h_fill = "white",
	h_color = "white",
	h_size = 0.001, # solid white hex
	url = "",
	filename = mask_file,
	dpi = 600,
	device = ragg::agg_png,
	bg = "black", # black corners outside hex
	white_around_sticker = FALSE
)

## apply the mask
## and crop it
img <- magick::image_read(raw_file)
mask <- magick::image_read(mask_file)

info <- magick::image_info(img)
mask <- magick::image_resize(mask, paste0(info$width, "x", info$height, "!"))

out <- magick::image_composite(img, mask, operator = "CopyOpacity")
magick::image_write(out, final_file)

if (clean) {
	base::unlink(c(mask_file, raw_file))
}
