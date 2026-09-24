## benchmark/benchmark-plots.R
##
## ggplot2 visualizations for the talib benchmark suite. Each plot
## function takes a tidy data.frame produced by tidy_bench() and returns
## a ggplot object; save_plots() writes all three to disk and is the
## single entry point used both by this script's stand-alone mode and by
## run-all.R, so the I/O lives in exactly one place.
##
## All themes use transparent backgrounds so the resulting PNGs blend in
## with both GitHub's light and dark color schemes.

suppressPackageStartupMessages({
	library(ggplot2)
	library(scales)
})


## Shared theme

## Transparent backgrounds plus a single mid-gray ink colour. The README
## is embedded in both GitHub's light (#ffffff) and dark (#0d1117)
## chrome, and one ~50% luminance gray (#7d7d7d) reads on either side
## without needing per-theme inversion. Titles get bold weight rather
## than a darker colour so they stay prominent on both backgrounds.
bench_theme <- function(base_size = 12) {
	transparent <- element_rect(fill = "transparent", colour = NA)
	ink <- "#7d7d7d"
	grid <- "#7d7d7d"
	theme_minimal(base_size = base_size) +
		theme(
			plot.background = transparent,
			panel.background = transparent,
			legend.background = transparent,
			legend.box.background = transparent,
			legend.key = transparent,
			strip.background = transparent,
			plot.title = element_text(face = "bold", color = ink),
			plot.subtitle = element_text(color = ink),
			plot.caption = element_text(color = ink, hjust = 0),
			strip.text = element_text(face = "bold", color = ink),
			axis.title = element_text(color = ink),
			axis.text = element_text(color = ink),
			panel.grid.minor = element_line(colour = grid, linewidth = 0.15),
			panel.grid.major = element_line(colour = grid, linewidth = 0.3),
			legend.position = "top",
			legend.title = element_blank(),
			legend.text = element_text(color = ink)
		)
}

## Palette for the three R-side dispatch paths in the overhead plot.
spec_colors <- c(
	"baseline" = "#1F77B4",
	"data.frame" = "#FF7F0E",
	"matrix" = "#2CA02C"
)

## Palette for the talib-vs-TTR plot. {talib} in steel-blue matches the
## package's house style; {TTR} in red provides clear contrast.
package_colors <- c(
	"{talib}" = "#1F77B4",
	"{TTR}" = "#D62728"
)


## Axis label helpers

## Render n as 1k / 10k / 100k / 1M so the x-axis ticks stay short and
## readable on a four-point log scale.
format_obs <- function(x) {
	out <- character(length(x))
	for (i in seq_along(x)) {
		v <- x[[i]]
		if (is.na(v)) {
			out[[i]] <- NA_character_
		} else if (v >= 1e6) {
			out[[i]] <- paste0(v / 1e6, "M")
		} else if (v >= 1e3) {
			out[[i]] <- paste0(v / 1e3, "k")
		} else {
			out[[i]] <- as.character(v)
		}
	}
	out
}

## Pick a sensible unit (ns / us / ms / s) per tick so a log-time y-axis
## reads like wall-clock numbers rather than scientific notation.
format_time <- function(x) {
	out <- character(length(x))
	for (i in seq_along(x)) {
		v <- x[[i]]
		if (is.na(v) || v <= 0) {
			out[[i]] <- NA_character_
		} else if (v < 1e-6) {
			out[[i]] <- sprintf("%.0fns", v * 1e9)
		} else if (v < 1e-3) {
			out[[i]] <- sprintf("%.0fus", v * 1e6)
		} else if (v < 1) {
			out[[i]] <- sprintf("%.0fms", v * 1e3)
		} else {
			out[[i]] <- sprintf("%.1fs", v)
		}
	}
	out
}


## Plots

## Overhead: one facet per indicator, three lines (baseline / data.frame
## / matrix). Each facet gets its own y scale because the absolute work
## per indicator differs by orders of magnitude.
plot_overhead <- function(data) {
	data$spec <- factor(
		data$spec,
		levels = c("baseline", "data.frame", "matrix")
	)
	data$indicator <- factor(data$indicator, levels = unique(data$indicator))

	ggplot(
		data,
		aes(x = n, y = median, colour = spec, group = spec)
	) +
		geom_ribbon(
			aes(ymin = min, ymax = max, fill = spec),
			alpha = 0.15,
			colour = NA
		) +
		geom_line(linewidth = 0.7) +
		geom_point(size = 1.7) +
		scale_x_log10(labels = format_obs, breaks = unique(data$n)) +
		scale_y_log10(labels = format_time) +
		scale_colour_manual(values = spec_colors) +
		scale_fill_manual(values = spec_colors, guide = "none") +
		facet_wrap(~indicator, ncol = 4, scales = "free_y") +
		labs(
			title = "{talib} R-side overhead",
			subtitle = "Median execution time vs observations, by dispatch path",
			x = "Observations",
			y = "Execution time (log)",
			caption = sprintf(
				"%d iterations per cell; ribbon shows min-max range.",
				max(data$n_itr)
			)
		) +
		bench_theme()
}

## TTR comparison: one facet per indicator, two lines ({talib} / {TTR}).
## The spec column is relabelled before becoming a factor so the legend
## matches the curly-fenced form used in the rest of the README.
plot_ttr <- function(data) {
	data$spec <- factor(
		paste0("{", data$spec, "}"),
		levels = c("{talib}", "{TTR}")
	)
	data$indicator <- factor(data$indicator, levels = unique(data$indicator))

	ggplot(
		data,
		aes(x = n, y = median, colour = spec, group = spec)
	) +
		geom_ribbon(
			aes(ymin = min, ymax = max, fill = spec),
			alpha = 0.15,
			colour = NA
		) +
		geom_line(linewidth = 0.7) +
		geom_point(size = 1.7) +
		scale_x_log10(labels = format_obs, breaks = unique(data$n)) +
		scale_y_log10(labels = format_time) +
		scale_colour_manual(values = package_colors) +
		scale_fill_manual(values = package_colors, guide = "none") +
		facet_wrap(~indicator, ncol = 4, scales = "free_y") +
		labs(
			title = "{talib} vs {TTR}",
			subtitle = "Median execution time vs observations, equivalent output bundles in each branch",
			x = "Observations",
			y = "Execution time (log)",
			caption = sprintf(
				"%d iterations per cell; ribbon shows min-max range.",
				max(data$n_itr)
			)
		) +
		bench_theme()
}

## Speedup: median(TTR) / median(talib), one number per (indicator, n)
## drawn as a labelled point. The x and y scales get extra expansion so
## the per-point "Nx" annotations do not collide with axes or facets.
plot_speedup <- function(data) {
	wide <- reshape(
		data[, c("indicator", "n", "spec", "median")],
		idvar = c("indicator", "n"),
		timevar = "spec",
		direction = "wide"
	)
	names(wide) <- sub("^median\\.", "", names(wide))
	wide$speedup <- wide$TTR / wide$talib
	wide$indicator <- factor(wide$indicator, levels = unique(data$indicator))

	ggplot(wide, aes(x = n, y = speedup)) +
		geom_hline(yintercept = 1, linetype = "dashed", colour = "grey60") +
		geom_line(linewidth = 0.7, colour = "#1F77B4") +
		geom_point(size = 1.7, colour = "#1F77B4") +
		geom_text(
			aes(label = sprintf("%.1fx", speedup)),
			vjust = -0.9,
			size = 3,
			colour = "#7d7d7d"
		) +
		scale_x_log10(
			labels = format_obs,
			breaks = unique(wide$n),
			expand = expansion(mult = 0.12)
		) +
		scale_y_log10(expand = expansion(mult = c(0.08, 0.25))) +
		facet_wrap(~indicator, ncol = 4) +
		labs(
			title = "{talib} speedup over {TTR}",
			subtitle = "{TTR} median / {talib} median; values above 1 mean {talib} is faster",
			x = "Observations",
			y = "Speedup (log)",
			caption = "Computed from median execution times in the same run."
		) +
		bench_theme()
}


## I/O

## Single place where the three PNGs are written. Called from the
## stand-alone entry point and from run-all.R so the ggsave arguments
## (size, dpi, transparent background) live in one location.
save_plots <- function(overhead, ttr, out_dir) {
	plots <- list(
		"plot-overhead.png" = plot_overhead(overhead),
		"plot-ttr.png" = plot_ttr(ttr),
		"plot-speedup.png" = plot_speedup(ttr)
	)
	for (name in names(plots)) {
		ggsave(
			file.path(out_dir, name),
			plots[[name]],
			width = 12,
			height = 6,
			dpi = 150,
			bg = "transparent"
		)
	}
	invisible(plots)
}


## Entry point

## Stand-alone invocation (Rscript / make bench-plots). Reads the
## existing RDS results and rewrites the PNGs. Skipped when sourced from
## run-all.R, which calls save_plots() itself with the in-memory data.
if (sys.nframe() == 0L) {
	out_dir <- file.path("benchmark", "results")
	overhead <- readRDS(file.path(out_dir, "overhead.rds"))
	ttr <- readRDS(file.path(out_dir, "ttr.rds"))
	save_plots(overhead, ttr, out_dir)
	message("\nSaved plots to benchmark/results/")
}
