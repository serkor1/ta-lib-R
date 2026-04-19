#!/usr/bin/env Rscript
## codegen/parity/csv_to_rds.R
##
## Converts the per-indicator CSV files produced by parity_gen into the
## .rds files the parity comparator (tests/parity/run_parity.R) consumes.
##
## Usage:
##   Rscript codegen/parity/csv_to_rds.R <input_dir> <output_dir>
##
## Each input CSV looks like:
##   # upstream=RSI
##   # opt_inputs=optInTimePeriod=14
##   # input_kind=Real
##   # input_columns=close
##   # output_types=Real
##   # lookback=14
##   # outBegIdx=14
##   # outNbElement=9986
##   # n=10000
##   outReal
##   NA
##   NA
##   ...
##   50.123
##
## Output .rds shape (per indicator):
##   list(
##     upstream     = "RSI",
##     opt_inputs   = list(optInTimePeriod = "14"),  # raw strings
##     input_kind   = "Real",
##     input_columns = "close",
##     output_types = c("Real"),
##     lookback     = 14L,
##     outBegIdx    = 14L,
##     outNbElement = 9986L,
##     output_names = c("outReal"),
##     outputs      = list(outReal = c(NA, NA, ..., 50.123, ...))
##   )
##
## No provenance fields (TA-Lib SHA, BTC SHA, timestamp) - the snapshot
## is regenerated from upstream on every `make parity` run, so drift
## detection is moot.

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2L) {
	stop("usage: csv_to_rds.R <input_dir> <output_dir>", call. = FALSE)
}
in_dir <- args[1L]
out_dir <- args[2L]

if (!dir.exists(in_dir)) stop("input dir does not exist: ", in_dir, call. = FALSE)
if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)

## Wipe any pre-existing .rds files so a regeneration can't leave behind
## stale snapshots for indicators that were removed from the package or
## from upstream.
old_rds <- list.files(out_dir, pattern = "\\.rds$", full.names = TRUE)
if (length(old_rds) > 0L) unlink(old_rds)

## Only keep snapshots for indicators the package actually exports.
## TA_ForEachFunc enumerates every upstream function (162 in current
## TA-Lib), but the R package wraps a subset (~120). Filtering here
## keeps the snapshot directory aligned with what the comparator can
## actually test.
suppressPackageStartupMessages(library(talib))
PKG_EXPORTS <- getNamespaceExports("talib")

## ---- Per-file conversion -----------------------------------------------

## Parse "key1=v1;key2=v2" into a named list of strings (or empty list).
parse_kv <- function(s) {
	if (is.null(s) || !nzchar(s)) return(list())
	pairs <- strsplit(s, ";", fixed = TRUE)[[1L]]
	out <- list()
	for (p in pairs) {
		if (!nzchar(p)) next
		eq <- regexpr("=", p, fixed = TRUE)
		if (eq < 1L) next
		key <- substr(p, 1L, eq - 1L)
		val <- substr(p, eq + 1L, nchar(p))
		out[[key]] <- val
	}
	out
}

## Extract "# key=value" comment lines from the head of a CSV.
read_metadata <- function(path) {
	con <- file(path, "r")
	on.exit(close(con))
	meta <- list()
	while (TRUE) {
		line <- readLines(con, n = 1L, warn = FALSE)
		if (length(line) == 0L) break
		if (!startsWith(line, "#")) break  # first non-comment = CSV header
		body <- sub("^#\\s*", "", line)
		eq <- regexpr("=", body, fixed = TRUE)
		if (eq < 1L) next
		key <- substr(body, 1L, eq - 1L)
		val <- substr(body, eq + 1L, nchar(body))
		meta[[key]] <- val
	}
	meta
}

convert_one <- function(csv_path) {
	meta <- read_metadata(csv_path)

	required <- c(
		"upstream", "opt_inputs", "input_kind", "input_columns",
		"output_types", "lookback", "outBegIdx", "outNbElement", "n"
	)
	missing <- setdiff(required, names(meta))
	if (length(missing) > 0L) {
		stop("missing metadata in ", csv_path, ": ",
		     paste(missing, collapse = ", "), call. = FALSE)
	}

	upstream <- meta$upstream
	output_types <- strsplit(meta$output_types, ",", fixed = TRUE)[[1L]]

	## Read the data block. comment.char = "#" skips the metadata header.
	## colClasses respects the per-column type (Integer outputs become integer
	## vectors; otherwise everything is double).
	col_classes <- ifelse(output_types == "Integer", "integer", "numeric")
	data <- read.csv(
		csv_path,
		comment.char = "#",
		na.strings = "NA",
		colClasses = col_classes,
		stringsAsFactors = FALSE,
		check.names = FALSE
	)
	output_names <- colnames(data)
	outputs <- as.list(data)
	names(outputs) <- output_names

	snap <- list(
		upstream = upstream,
		opt_inputs = parse_kv(meta$opt_inputs),
		input_kind = meta$input_kind,
		input_columns = meta$input_columns,
		output_types = output_types,
		lookback = as.integer(meta$lookback),
		outBegIdx = as.integer(meta$outBegIdx),
		outNbElement = as.integer(meta$outNbElement),
		output_names = output_names,
		outputs = outputs
	)

	rds_path <- file.path(out_dir, paste0(upstream, ".rds"))
	saveRDS(snap, rds_path, compress = "xz")
	rds_path
}

## ---- Run ---------------------------------------------------------------

csv_files <- list.files(in_dir, pattern = "\\.csv$", full.names = TRUE)
if (length(csv_files) == 0L) {
	stop("no CSV files found in ", in_dir, call. = FALSE)
}

n_ok <- 0L
n_err <- 0L
n_skip <- 0L
errors <- character()
for (f in csv_files) {
	## Cheap upstream-name extraction: the file basename equals the upstream
	## function name. Skip without parsing if the package doesn't wrap it.
	upstream <- sub("\\.csv$", "", basename(f))
	if (!(upstream %in% PKG_EXPORTS)) {
		n_skip <- n_skip + 1L
		next
	}
	res <- tryCatch(convert_one(f), error = function(e) e)
	if (inherits(res, "error")) {
		cat(sprintf("  ERR  %s : %s\n", basename(f), conditionMessage(res)))
		errors <- c(errors, basename(f))
		n_err <- n_err + 1L
	} else {
		n_ok <- n_ok + 1L
	}
}

cat(sprintf("\nWrote %d .rds, skipped %d (not wrapped), %d errors -> %s\n",
            n_ok, n_skip, n_err, out_dir))
if (n_err > 0L) {
	cat("Failed files: ", paste(errors, collapse = ", "), "\n", sep = "")
	quit(status = 1L)
}
