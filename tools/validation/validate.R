#!/usr/bin/env Rscript
# tools/validation/validate.R
#
# Validate R package output against bare TA-Lib C calls.
# Run from the repository root:
#
#   Rscript tools/validation/validate.R
#
# Prerequisites:
#   1. Package installed:  R CMD INSTALL .
#   2. Shared library compiled (from repo root):
#      PKG_CFLAGS="-Isrc/ta-lib/local/include -Isrc/ta-lib/local/include/ta-lib" \
#      PKG_LIBS="src/ta-lib/local/lib/libta-lib.a -lm" \
#      R CMD SHLIB tools/validation/validate.c

library(talib)

## load validation shared library
so_path <- file.path(
	"tools",
	"validation",
	paste0("validate", .Platform$dynlib.ext)
)

if (!file.exists(so_path)) {
	stop("Validation library not found: ", so_path)
}
dyn.load(so_path)

## test infrastructure
results <- list()

check <- function(
	indicator,
	column,
	pkg_val,
	ref_val,
	tol = sqrt(.Machine$double.eps)
) {
	label <- paste0(indicator, "/", column)

	pkg_val <- as.numeric(pkg_val)
	ref_val <- as.numeric(ref_val)

	## compare including NA positions
	eq <- all.equal(pkg_val, ref_val, tolerance = tol, check.attributes = FALSE)

	pass <- isTRUE(eq)
	results[[length(results) + 1L]] <<- list(
		label = label,
		pass = pass,
		detail = if (!pass) eq
	)

	if (pass) {
		cat(sprintf("  PASS  %s\n", label))
	} else {
		cat(sprintf("  FAIL  %s\n", label))
		cat(sprintf("        %s\n", paste(eq, collapse = "\n        ")))
	}
}

## test data
close <- as.double(BTC$close)
high <- as.double(BTC$high)
low <- as.double(BTC$low)

cat("=== TA-Lib Core Validation ===\n\n")

## --- SMA ---
cat("SMA(n=14):\n")
pkg <- as.matrix(simple_moving_average(BTC, n = 14L))
ref <- .Call("validate_SMA", close, 14L, PACKAGE = "validate")
check("SMA", "SMA", pkg[, 1], ref[, 1])

## --- RSI ---
cat("\nRSI(n=14):\n")
pkg <- as.matrix(relative_strength_index(BTC, n = 14L))
ref <- .Call("validate_RSI", close, 14L, PACKAGE = "validate")
check("RSI", "RSI", pkg[, 1], ref[, 1])

## --- BBANDS ---
cat("\nBBANDS(ma=SMA(20), sd=2):\n")
pkg <- as.matrix(bollinger_bands(BTC, ma = SMA(n = 20L), sd = 2))
ref <- .Call("validate_BBANDS", close, 20L, 2.0, 2.0, 0L, PACKAGE = "validate")
check("BBANDS", "UpperBand", pkg[, 1], ref[, 1])
check("BBANDS", "MiddleBand", pkg[, 2], ref[, 2])
check("BBANDS", "LowerBand", pkg[, 3], ref[, 3])

## --- ATR ---
cat("\nATR(n=14):\n")
pkg <- as.matrix(average_true_range(BTC, n = 14L))
ref <- .Call("validate_ATR", high, low, close, 14L, PACKAGE = "validate")
check("ATR", "ATR", pkg[, 1], ref[, 1])

## --- Summary ---
n_pass <- sum(vapply(results, `[[`, logical(1), "pass"))
n_fail <- length(results) - n_pass

cat(sprintf(
	"\n=== %d passed, %d failed (of %d) ===\n",
	n_pass,
	n_fail,
	length(results)
))

if (n_fail > 0L) {
	quit(status = 1L)
}
