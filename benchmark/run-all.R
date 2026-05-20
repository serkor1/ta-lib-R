## benchmark/run-all.R
##
## Drive the full benchmark suite end to end:
##
##   1. Overhead benchmark (.Call vs data.frame vs matrix).
##   2. TTR comparison (talib vs TTR).
##   3. Save PNGs of the three plots.
##
## Invoke via `make bench` or `Rscript benchmark/run-all.R`. The full
## grid (8 indicators x 4 sizes x 1000 iters, twice) runs in minutes;
## the largest TTR cells dominate the wall clock.

source("benchmark/benchmark-utils.R")

out_dir <- file.path("benchmark", "results")
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

## Echo the configuration once so the log shows what was actually run.
message("Sizes:      ", paste(format(BENCHMARK_SIZES, big.mark = ","), collapse = ", "))
message("Iterations: ", BENCHMARK_ITERATIONS)
message("Warmup:     ", BENCHMARK_WARMUP)


## Overhead benchmark

## local = TRUE keeps run_overhead in this frame so we can call it
## directly without polluting the global env. The sourced file's
## stand-alone entry point is skipped because sys.nframe() > 0 here.
message("\n=== Overhead benchmark (.Call vs data.frame vs matrix) ===")
source("benchmark/benchmark-overhead.R", local = TRUE)
overhead <- run_overhead()
saveRDS(overhead, file.path(out_dir, "overhead.rds"))


## TTR comparison

message("\n=== TTR comparison (talib vs TTR) ===")
source("benchmark/benchmark-ttr.R", local = TRUE)
ttr <- run_ttr()
saveRDS(ttr, file.path(out_dir, "ttr.rds"))


## Plots

## save_plots writes all three PNGs with the same ggsave settings; we
## delegate so the I/O parameters live in benchmark-plots.R only.
message("\n=== Plots ===")
source("benchmark/benchmark-plots.R", local = TRUE)
save_plots(overhead, ttr, out_dir)

message("\nAll done. Results in benchmark/results/")
