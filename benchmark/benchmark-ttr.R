## benchmark/benchmark-ttr.R
##
## Compare talib (C implementation) against TTR (R implementation, with
## some indicators C-backed) at the user level. For each indicator we
## time two expressions:
##
##   1. talib - the talib equivalent of what TTR returns.
##   2. TTR   - the natural TTR call, with the same period / deviation
##              parameters so the algorithms are matched.
##
## "Equivalent" means the two branches produce the same set of derived
## series per call. TTR tends to return bundles (e.g. TTR::ADX returns
## DIp, DIn, DX, ADX in one matrix), while talib exposes each indicator
## as a separate function. Where TTR's API forces extra outputs we
## compose the matching talib calls (or derive the extras in R) so both
## packages do the same algorithmic work in each timed cell. Where
## talib's API returns the extras (MACD histogram) we synthesise the
## same column on the TTR side. The result is an apples-to-apples
## comparison; the residual gap reflects the inner loops, not API shape.

suppressPackageStartupMessages({
	library(talib)
	library(TTR)
	library(bench)
})

source("benchmark/benchmark-utils.R")


## Indicator factories

ttr_factories <- list(
	BBANDS = function(df, hlc) {
		close <- df$close
		list(
			## TTR::BBands returns dn/mavg/up plus pctB (the %B oscillator).
			## talib's bollinger_bands omits pctB, so we derive it from the
			## same series as TTR does: pctB = (close - dn) / (up - dn).
			talib = function() {
				bb <- talib::bollinger_bands(df, ma = talib::SMA(n = 20))
				bb$pctB <- (close - bb$LowerBand) /
					(bb$UpperBand - bb$LowerBand)
				bb
			},
			TTR = function() TTR::BBands(close, n = 20, sd = 2)
		)
	},
	RSI = function(df, hlc) {
		## Both branches return a single column already.
		close <- df$close
		list(
			talib = function() talib::relative_strength_index(df, n = 14),
			TTR = function() TTR::RSI(close, n = 14)
		)
	},
	MACD = function(df, hlc) {
		close <- df$close
		list(
			## talib's MACD returns MACD, Signal, Hist (3 columns); TTR's
			## MACD returns only macd and signal. Compute hist on the TTR
			## side to match the bundle size; hist is just macd - signal.
			talib = function() {
				talib::moving_average_convergence_divergence(df)
			},
			TTR = function() {
				m <- TTR::MACD(
					close,
					nFast = 12,
					nSlow = 26,
					nSig = 9,
					maType = "EMA"
				)
				cbind(m, hist = m[, "macd"] - m[, "signal"])
			}
		)
	},
	ATR = function(df, hlc) {
		## TTR::ATR returns tr, atr, trueHigh, trueLow. talib::ATR only
		## returns atr, so we derive the other three from the same H/L/C
		## inputs that TTR uses:
		##   trueHigh = pmax(high, lag(close))
		##   trueLow  = pmin(low,  lag(close))
		##   tr       = trueHigh - trueLow
		## This requires one talib C call plus three vectorized R ops.
		high <- df$high
		low <- df$low
		close <- df$close
		list(
			talib = function() {
				atr <- talib::average_true_range(df, n = 14)
				prevC <- c(NA, close[-length(close)])
				trueHigh <- pmax(high, prevC)
				trueLow <- pmin(low, prevC)
				cbind(
					tr = trueHigh - trueLow,
					atr = atr[, 1],
					trueHigh = trueHigh,
					trueLow = trueLow
				)
			},
			TTR = function() TTR::ATR(hlc, n = 14)
		)
	},
	SMA = function(df, hlc) {
		## Single column in both branches.
		close <- df$close
		list(
			talib = function() talib::simple_moving_average(df, n = 20),
			TTR = function() TTR::SMA(close, n = 20)
		)
	},
	EMA = function(df, hlc) {
		## Single column in both branches.
		close <- df$close
		list(
			talib = function() talib::exponential_moving_average(df, n = 20),
			TTR = function() TTR::EMA(close, n = 20)
		)
	},
	ADX = function(df, hlc) {
		## TTR::ADX returns the full DI+/DI-/DX/ADX bundle from one
		## internal pass. talib exposes each as a separate wrapper, so we
		## call all four and cbind them. This is the "fair" cost: a real
		## user wanting all four outputs from talib pays exactly this.
		list(
			talib = function() {
				cbind(
					DIp = talib::PLUS_DI(df, n = 14)[, 1],
					DIn = talib::MINUS_DI(df, n = 14)[, 1],
					DX = talib::DX(df, n = 14)[, 1],
					ADX = talib::average_directional_movement_index(
						df,
						n = 14
					)[, 1]
				)
			},
			TTR = function() TTR::ADX(hlc, n = 14)
		)
	},
	STOCH = function(df, hlc) {
		## TTR::stoch returns fastK, fastD, slowD. talib::stochastic only
		## exposes the smoothed pair SlowK (= fastD) and SlowD; the raw
		## fastK is computed internally but not returned. We use
		## talib::STOCHF (which returns FastK and FastD) and add a third
		## SMA pass to recover slowD. Two C calls vs TTR's single
		## internal pipeline; matches the work TTR does.
		list(
			talib = function() {
				sf <- talib::STOCHF(df, fastk = 14, fastd = talib::SMA(n = 3))
				cbind(
					fastK = sf$FastK,
					fastD = sf$FastD,
					slowD = talib::SMA(sf$FastD, n = 3)
				)
			},
			TTR = function() {
				TTR::stoch(hlc, nFastK = 14, nFastD = 3, nSlowD = 3)
			}
		)
	}
)


## Driver

## Same shape as run_overhead: walk every (indicator, n) cell, warm up,
## time, collect tidy rows. The only structural difference is the HLC
## matrix prep, which TTR's multi-input indicators need.
run_ttr <- function(
	indicators = names(ttr_factories),
	sizes = BENCHMARK_SIZES,
	iterations = BENCHMARK_ITERATIONS,
	warmup_n = BENCHMARK_WARMUP
) {
	results <- list()
	for (indicator in indicators) {
		factory <- ttr_factories[[indicator]]
		message(sprintf("\n[ttr] %s", indicator))
		for (n in sizes) {
			banner(indicator, n)
			df <- make_ohlc(n)
			hlc <- as.matrix(df[, c("high", "low", "close")])
			exprs <- factory(df, hlc)

			## Prime caches and the allocator before bench starts the clock.
			warmup(exprs, reps = warmup_n)

			bm <- bench::mark(
				talib = exprs$talib(),
				TTR = exprs$TTR(),
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

## Stand-alone invocation (Rscript / make bench-ttr). When this file is
## sourced from run-all.R the guard skips this block.
if (sys.nframe() == 0L) {
	ttr <- run_ttr()

	out_dir <- file.path("benchmark", "results")
	dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)
	saveRDS(ttr, file.path(out_dir, "ttr.rds"))

	message("\nSaved TTR comparison to benchmark/results/ttr.rds")
}
