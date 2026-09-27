## script: favicons
## author: Serkan Korkmaz
## objective: Generate favicons from the SVG logo into
## pkgdown/favicon so pkgdown::init_site() skips the
## realfavicongenerator.net API (it rejects SVG logos with HTTP 500).
##
## called by the pkgdown Makefile target and .github/workflows/pkgdown.yaml
svg <- "man/figures/logo.svg"
dir.create("pkgdown/favicon", recursive = TRUE, showWarnings = FALSE)

file.copy(svg, "pkgdown/favicon/favicon.svg", overwrite = TRUE)
rsvg::rsvg_png(svg, "pkgdown/favicon/favicon-96x96.png", width = 96)
rsvg::rsvg_png(svg, "pkgdown/favicon/apple-touch-icon.png", width = 180)

tmp <- tempfile(fileext = ".png")
rsvg::rsvg_png(svg, tmp, width = 48)
magick::image_write(
	magick::image_read(tmp),
	"pkgdown/favicon/favicon.ico",
	format = "ico"
)
