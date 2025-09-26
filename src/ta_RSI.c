// Interface to ta_RSI (Relative Strength Index)
//
// Parameters
//   inReal        : numeric vector of source prices.
//   optTimePeriod : integer, lookback period (commonly 14).
//
// Description
//   Computes the single‐output RSI over the series. Returns an
//   unnamed numeric vector of length n, padded with NA_REAL.
#include "lib.h"
#include "names.h"
#include "ta_defs.h"
#include "ta_func.h"
#include <R.h>
#include <Rinternals.h>
#include <ta_libc.h>

SEXP impl_ta_RSI(SEXP inReal, SEXP optTimePeriod) {
  int protect_count = 0;
  int n = LENGTH(inReal);
  double *restrict src = REAL(inReal);
  int period = INTEGER(optTimePeriod)[0];

  SEXP result = PROTECT(allocVector(REALSXP, n));
  protect_count++;
  double *rsi = REAL(result);

  int minimum_lookback = TA_RSI_Lookback(period);
  if (n < minimum_lookback) {
    Rf_warning("Input length (%d) is smaller than required lookback (%d).", n,
               minimum_lookback);

    for (size_t i = 0; i < n; ++i) {
      rsi[i] = NA_REAL;
    }

  } else {

    int outBeg = 0, outNb = 0;
    // clang-format off
    TA_RetCode return_code = TA_RSI(
      0, 
      n - 1, 
      src, 
      period, 
      &outBeg, 
      &outNb, 
      rsi
    );
    // clang-format on

    if (return_code != TA_SUCCESS) {
      UNPROTECT(protect_count);
      Rf_error("Failed with error code %d", return_code);
    }

    // shift
    shift_array(rsi, n, outBeg);
  }

  UNPROTECT(protect_count);
  return result;
}
