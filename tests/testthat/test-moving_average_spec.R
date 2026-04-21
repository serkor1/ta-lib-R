## Moving-Average specification mode
##
## When an MA function is called without 'x' it returns a named list
## ("spec") consumed by indicators that support multiple MA types
## (APO, PPO, BBANDS, MACDEXT, STOCH, STOCHF, STOCHRSI).
##
## Hand-written (not generated via codegen/) because the contract is
## cross-cutting across the nine MA functions and would otherwise
## require threading maType through generate_unit-tests.sh.

## ---- expected spec per MA -------------------------------------------------
## Each row: function, alias, maType code, default-field values.
## Simple MAs take n only; MAMA takes fast/slow; T3 takes n/vfactor.
.ma_specs <- list(
	list(
		name = "SMA",
		fun = simple_moving_average,
		alias = SMA,
		maType = 0L,
		n = 30L
	),
	list(
		name = "EMA",
		fun = exponential_moving_average,
		alias = EMA,
		maType = 1L,
		n = 30L
	),
	list(
		name = "WMA",
		fun = weighted_moving_average,
		alias = WMA,
		maType = 2L,
		n = 30L
	),
	list(
		name = "DEMA",
		fun = double_exponential_moving_average,
		alias = DEMA,
		maType = 3L,
		n = 30L
	),
	list(
		name = "TEMA",
		fun = triple_exponential_moving_average,
		alias = TEMA,
		maType = 4L,
		n = 30L
	),
	list(
		name = "TRIMA",
		fun = triangular_moving_average,
		alias = TRIMA,
		maType = 5L,
		n = 30L
	),
	list(
		name = "KAMA",
		fun = kaufman_adaptive_moving_average,
		alias = KAMA,
		maType = 6L,
		n = 30L
	)
)

## ---- shape and default contract (simple n-only MAs) ------------------------
for (.spec in .ma_specs) {
	local({
		spec <- .spec

		testthat::test_that(
			sprintf("%s() without x returns list(n, maType)", spec$name),
			{
				out <- spec$fun()

				testthat::expect_type(out, "list")
				testthat::expect_named(out, c("n", "maType"))
				testthat::expect_identical(out$maType, spec$maType)
				testthat::expect_identical(out$n, spec$n)
			}
		)

		testthat::test_that(
			sprintf(
				"%s() alias returns identical spec to long-form",
				spec$name
			),
			{
				testthat::expect_identical(spec$alias(), spec$fun())
				testthat::expect_identical(spec$alias(n = 7), spec$fun(n = 7))
			}
		)

		testthat::test_that(
			sprintf(
				"%s() coerces n to integer and honours explicit value",
				spec$name
			),
			{
				## explicit integer round-trips
				testthat::expect_identical(spec$fun(n = 14)$n, 14L)
				## double is truncated to integer (matches as.integer semantics)
				testthat::expect_identical(spec$fun(n = 14.7)$n, 14L)
				## storage type is integer even when caller passes double
				testthat::expect_identical(typeof(spec$fun(n = 5)$n), "integer")
			}
		)
	})
}

## ---- MAMA (n + fast / slow) ------------------------------------------------
## MAMA carries 'n' as a spec-only field so downstream consumers
## (BBANDS, STOCH, MACDEXT, ...) can read ma$n uniformly even though
## MAMA's own standalone calculation is adaptive and does not use n.
testthat::test_that("MAMA() without x returns list(n, fast, slow, maType = 7L)", {
	out <- mesa_adaptive_moving_average()

	testthat::expect_type(out, "list")
	testthat::expect_named(out, c("n", "fast", "slow", "maType"))
	testthat::expect_identical(out$maType, 7L)
	testthat::expect_identical(out$n, 30L)
	testthat::expect_identical(out$fast, 0.5)
	testthat::expect_identical(out$slow, 0.05)
})

testthat::test_that("MAMA() alias matches long-form and coerces types", {
	testthat::expect_identical(MAMA(), mesa_adaptive_moving_average())
	testthat::expect_identical(
		MAMA(n = 14, fast = 0.3, slow = 0.1),
		mesa_adaptive_moving_average(n = 14, fast = 0.3, slow = 0.1)
	)

	out <- MAMA(n = 14.7, fast = 1L, slow = 0L)
	testthat::expect_identical(out$n, 14L)
	testthat::expect_identical(typeof(out$n), "integer")
	testthat::expect_identical(out$fast, 1)
	testthat::expect_identical(out$slow, 0)
	testthat::expect_identical(typeof(out$fast), "double")
	testthat::expect_identical(typeof(out$slow), "double")
})

## 'n' is spec-only: MAMA's standalone output must NOT depend on it.
## Regression guard against someone wiring 'n' into the C call.
testthat::test_that("MAMA(x, n) ignores n in standalone calculation", {
	default_out <- mesa_adaptive_moving_average(BTC)
	n14_out <- mesa_adaptive_moving_average(BTC, n = 14)
	n50_out <- mesa_adaptive_moving_average(BTC, n = 50)

	testthat::expect_equal(default_out, n14_out)
	testthat::expect_equal(default_out, n50_out)
})

## ---- T3 (n + vfactor) ------------------------------------------------------
testthat::test_that("T3() without x returns list(n, vfactor, maType = 8L)", {
	out <- t3_exponential_moving_average()

	testthat::expect_type(out, "list")
	testthat::expect_named(out, c("n", "vfactor", "maType"))
	testthat::expect_identical(out$maType, 8L)
	testthat::expect_identical(out$n, 5L)
	testthat::expect_identical(out$vfactor, 0.7)
})

testthat::test_that("T3() alias matches long-form and coerces types", {
	testthat::expect_identical(T3(), t3_exponential_moving_average())
	testthat::expect_identical(
		T3(n = 10, vfactor = 0.5),
		t3_exponential_moving_average(n = 10, vfactor = 0.5)
	)

	out <- T3(n = 9.9, vfactor = 1L)
	testthat::expect_identical(out$n, 9L)
	testthat::expect_identical(out$vfactor, 1)
	testthat::expect_identical(typeof(out$n), "integer")
	testthat::expect_identical(typeof(out$vfactor), "double")
})

## ---- downstream integration ------------------------------------------------
## Every MA spec carries 'n' + 'maType' and must drive every consumer:
## APO / PPO (read maType only) and
## BBANDS / stochastic / STOCHF / STOCHRSI / MACDEXT (read both n and maType).

.all_specs <- list(
	SMA = SMA,
	EMA = EMA,
	WMA = WMA,
	DEMA = DEMA,
	TEMA = TEMA,
	TRIMA = TRIMA,
	KAMA = KAMA,
	MAMA = MAMA,
	T3 = T3
)

for (.nm in names(.all_specs)) {
	local({
		nm <- .nm
		mk <- .all_specs[[nm]]

		testthat::test_that(
			sprintf("APO() accepts %s() spec", nm),
			{
				out <- absolute_price_oscillator(BTC, ma = mk())
				testthat::expect_s3_class(out, "data.frame")
				testthat::expect_equal(nrow(out), nrow(BTC))
				testthat::expect_true(any(is.finite(out[[1]])))
			}
		)

		testthat::test_that(
			sprintf("PPO() accepts %s() spec", nm),
			{
				out <- percentage_price_oscillator(BTC, ma = mk())
				testthat::expect_s3_class(out, "data.frame")
				testthat::expect_equal(nrow(out), nrow(BTC))
				testthat::expect_true(any(is.finite(out[[1]])))
			}
		)

		testthat::test_that(
			sprintf("BBANDS() accepts %s() spec with explicit n", nm),
			{
				out <- bollinger_bands(BTC, ma = mk(n = 10))
				testthat::expect_s3_class(out, "data.frame")
				testthat::expect_equal(nrow(out), nrow(BTC))
				testthat::expect_true(any(is.finite(out[[1]])))
			}
		)

		testthat::test_that(
			sprintf("stochastic() accepts %s() spec for slowk/slowd", nm),
			{
				out <- stochastic(BTC, slowk = mk(n = 3), slowd = mk(n = 3))
				testthat::expect_s3_class(out, "data.frame")
				testthat::expect_equal(nrow(out), nrow(BTC))
				testthat::expect_true(any(is.finite(out[[1]])))
			}
		)

		testthat::test_that(
			sprintf("STOCHF() accepts %s() spec for fastd", nm),
			{
				out <- STOCHF(BTC, fastd = mk(n = 3))
				testthat::expect_s3_class(out, "data.frame")
				testthat::expect_equal(nrow(out), nrow(BTC))
				testthat::expect_true(any(is.finite(out[[1]])))
			}
		)

		testthat::test_that(
			sprintf("STOCHRSI() accepts %s() spec for fastd", nm),
			{
				out <- STOCHRSI(BTC, fastd = mk(n = 3))
				testthat::expect_s3_class(out, "data.frame")
				testthat::expect_equal(nrow(out), nrow(BTC))
				testthat::expect_true(any(is.finite(out[[1]])))
			}
		)

		testthat::test_that(
			sprintf("MACDEXT() accepts %s() spec for fast/slow/signal", nm),
			{
				out <- extended_moving_average_convergence_divergence(
					BTC,
					fast = mk(n = 5),
					slow = mk(n = 10),
					signal = mk(n = 3)
				)
				testthat::expect_s3_class(out, "data.frame")
				testthat::expect_equal(nrow(out), nrow(BTC))
				testthat::expect_true(any(is.finite(out[[1]])))
			}
		)
	})
}

## ---- maType drives the consumer's output -----------------------------------
## Swap EMA for SMA in APO: output must differ. Protects against consumers
## silently ignoring the spec (the bug shape that shape tests alone miss).
testthat::test_that("APO output depends on the MA spec (EMA != SMA)", {
	out_sma <- absolute_price_oscillator(BTC, ma = SMA(n = 9))
	out_ema <- absolute_price_oscillator(BTC, ma = EMA(n = 9))

	testthat::expect_equal(dim(out_sma), dim(out_ema))
	## require an actual numerical difference somewhere in the overlap
	testthat::expect_false(
		isTRUE(all.equal(out_sma[[1]], out_ema[[1]]))
	)
})

testthat::test_that("BBANDS output depends on the MA spec (WMA != SMA)", {
	out_sma <- bollinger_bands(BTC, ma = SMA(n = 10))
	out_wma <- bollinger_bands(BTC, ma = WMA(n = 10))

	testthat::expect_equal(dim(out_sma), dim(out_wma))
	testthat::expect_false(
		isTRUE(all.equal(out_sma[[1]], out_wma[[1]]))
	)
})

## 'n' must drive the consumer's window. If a future change drops ma$n
## lookup in favour of a hard-coded default, these tests catch it.
testthat::test_that("BBANDS consumes ma$n (different n => different output)", {
	out_10 <- bollinger_bands(BTC, ma = SMA(n = 10))
	out_30 <- bollinger_bands(BTC, ma = SMA(n = 30))

	testthat::expect_false(
		isTRUE(all.equal(out_10[[1]], out_30[[1]]))
	)
})

testthat::test_that("stochastic() consumes slowk$n (different n => different output)", {
	out_3 <- stochastic(BTC, slowk = SMA(n = 3), slowd = SMA(n = 3))
	out_7 <- stochastic(BTC, slowk = SMA(n = 7), slowd = SMA(n = 7))

	testthat::expect_false(
		isTRUE(all.equal(out_3[[1]], out_7[[1]]))
	)
})
