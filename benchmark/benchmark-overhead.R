## benchmark/benchmark-overhead.R
##
## Measure the overhead that talib's R wrappers add on top of the bare
## .Call into the bundled TA-Lib C library. For each indicator we time
## three expressions at every n:
##
##   1. baseline   - a raw .Call against the registered native symbol,
##                   using exactly the arguments the wrapper would pass.
##   2. data.frame - talib's data.frame S3 method (series() column
##                   selection + map_dfr() to wrap the result).
##   3. matrix     - talib's matrix S3 method (series() column selection,
##                   no map_dfr).
##
## All three call the same underlying C routine. Any difference in
## timing is pure R-side overhead. Every talib symbol is referenced
## through talib:: so that load order with TTR (whose SMA / EMA / RSI /
## ATR / ADX / MACD shadow talib's exports) cannot perturb the result.

suppressPackageStartupMessages({
	library(talib)
	library(bench)
})

source("benchmark/benchmark-utils.R")


## Native symbols

## Resolve the registered C symbols once. Caching them out of talib's
## namespace makes the baseline expression a literal .Call against a
## pointer, with no per-iteration symbol lookup.
ns <- asNamespace("talib")
C_BBANDS <- get("C_impl_ta_BBANDS", envir = ns)
C_RSI <- get("C_impl_ta_RSI", envir = ns)
C_MACD <- get("C_impl_ta_MACD", envir = ns)
C_ATR <- get("C_impl_ta_ATR", envir = ns)
C_SMA <- get("C_impl_ta_SMA", envir = ns)
C_EMA <- get("C_impl_ta_EMA", envir = ns)
C_ADX <- get("C_impl_ta_ADX", envir = ns)
C_STOCH <- get("C_impl_ta_STOCH", envir = ns)


## Indicator factories

## Each factory takes the OHLCV data.frame and its matrix mirror and
## returns three nullary closures whose bodies are the .Call the wrapper
## would emit. Using closures (rather than substituted expressions) lets
## bench::mark see uniform call sites across indicators and lets the
## driver share one warmup loop. The closures capture df / mat by
## reference, so the inner timed expressions allocate nothing extra.
overhead_factories <- list(
	BBANDS = function(df, mat) {
		list(
			baseline = function() {
				.Call(C_BBANDS, df$close, 20L, 2, 2, 0L, FALSE)
			},
			data.frame = function() {
				talib::bollinger_bands(df, ma = talib::SMA(n = 20))
			},
			matrix = function() {
				talib::bollinger_bands(mat, ma = talib::SMA(n = 20))
			}
		)
	},
	RSI = function(df, mat) {
		list(
			baseline = function() .Call(C_RSI, df$close, 14L, FALSE),
			data.frame = function() talib::relative_strength_index(df, n = 14),
			matrix = function() talib::relative_strength_index(mat, n = 14)
		)
	},
	MACD = function(df, mat) {
		list(
			baseline = function() {
				.Call(C_MACD, df$close, 12L, 26L, 9L, FALSE)
			},
			data.frame = function() {
				talib::moving_average_convergence_divergence(df)
			},
			matrix = function() {
				talib::moving_average_convergence_divergence(mat)
			}
		)
	},
	ATR = function(df, mat) {
		list(
			baseline = function() {
				.Call(C_ATR, df$high, df$low, df$close, 14L, FALSE)
			},
			data.frame = function() talib::average_true_range(df, n = 14),
			matrix = function() talib::average_true_range(mat, n = 14)
		)
	},
	SMA = function(df, mat) {
		## The talib wrapper coerces with as.double() before .Call, so the
		## baseline does the same; we want the C work to be apples to apples.
		list(
			baseline = function() {
				.Call(C_SMA, as.double(df$close), 20L, FALSE)
			},
			data.frame = function() {
				talib::simple_moving_average(df, n = 20)
			},
			matrix = function() {
				talib::simple_moving_average(mat, n = 20)
			}
		)
	},
	EMA = function(df, mat) {
		## Same as SMA: the wrapper does an explicit as.double() coercion.
		list(
			baseline = function() {
				.Call(C_EMA, as.double(df$close), 20L, FALSE)
			},
			data.frame = function() {
				talib::exponential_moving_average(df, n = 20)
			},
			matrix = function() {
				talib::exponential_moving_average(mat, n = 20)
			}
		)
	},
	ADX = function(df, mat) {
		list(
			baseline = function() {
				.Call(
					C_ADX,
					df$high,
					df$low,
					df$close,
					14L,
					FALSE
				)
			},
			data.frame = function() {
				talib::average_directional_movement_index(df, n = 14)
			},
			matrix = function() {
				talib::average_directional_movement_index(mat, n = 14)
			}
		)
	},
	STOCH = function(df, mat) {
		list(
			baseline = function() {
				.Call(
					C_STOCH,
					df$high,
					df$low,
					df$close,
					14L,
					3L,
					0L,
					3L,
					0L,
					FALSE
				)
			},
			data.frame = function() {
				talib::stochastic(
					df,
					fastk = 14,
					slowk = talib::SMA(n = 3),
					slowd = talib::SMA(n = 3)
				)
			},
			matrix = function() {
				talib::stochastic(
					mat,
					fastk = 14,
					slowk = talib::SMA(n = 3),
					slowd = talib::SMA(n = 3)
				)
			}
		)
	}
)


## Driver

## Sweep every (indicator, n) cell. For each cell we build fresh data,
## warm up, then hand the three closures to bench::mark and tag the tidy
## result with the indicator name and size. Rows from all cells are
## rbind-ed at the end into one long data.frame for plotting.
run_overhead <- function(
	indicators = names(overhead_factories),
	sizes = BENCHMARK_SIZES,
	iterations = BENCHMARK_ITERATIONS,
	warmup_n = BENCHMARK_WARMUP
) {
	results <- list()
	for (indicator in indicators) {
		factory <- overhead_factories[[indicator]]
		message(sprintf("\n[overhead] %s", indicator))
		for (n in sizes) {
			banner(indicator, n)
			df <- make_ohlc(n)
			mat <- as.matrix(df)
			exprs <- factory(df, mat)

			## Prime caches and the allocator before bench starts the clock.
			warmup(exprs, reps = warmup_n)

			bm <- bench::mark(
				baseline = exprs$baseline(),
				data.frame = exprs$data.frame(),
				matrix = exprs$matrix(),
				iterations = iterations,
				check = FALSE,
				filter_gc = FALSE,
				memory = TRUE,
				time_unit = "s"
			)

			results[[length(results) + 1L]] <- tidy_bench(
				bm,
				indicator = indicator,
				n = n
			)
		}
	}
	do.call(rbind, results)
}


## Entry point

## Only runs when this file is invoked directly (Rscript / make
## bench-overhead). When sourced from run-all.R the guard skips this
## block; run-all.R calls run_overhead() and saves the result itself.
if (sys.nframe() == 0L) {
	overhead <- run_overhead()

	out_dir <- file.path("benchmark", "results")
	dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)
	saveRDS(overhead, file.path(out_dir, "overhead.rds"))

	message("\nSaved overhead results to benchmark/results/overhead.rds")
}
