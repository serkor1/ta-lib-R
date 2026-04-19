#!/usr/bin/env Rscript
## codegen/parity/btc_to_csv.R
##
## One-shot exporter: dumps the BTC OHLCV columns as a flat CSV in the
## column order parity_gen.c expects (open,high,low,close,volume).
##
## Usage:
##   Rscript codegen/parity/btc_to_csv.R <output_path>

suppressPackageStartupMessages(library(talib))

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 1L) {
	stop("usage: btc_to_csv.R <output_path>", call. = FALSE)
}
out_path <- args[1L]

stopifnot(all(c("open", "high", "low", "close", "volume") %in% colnames(BTC)))

write.table(
	BTC[, c("open", "high", "low", "close", "volume")],
	file = out_path,
	sep = ",",
	row.names = FALSE,
	col.names = TRUE,
	quote = FALSE
)

cat(sprintf("Wrote %d rows to %s\n", nrow(BTC), out_path))
