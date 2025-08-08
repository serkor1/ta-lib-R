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
#include "ta_defs.h"
#include <R.h>
#include <Rinternals.h>
#include <ta_libc.h>

SEXP impl_ta_RSI(SEXP inReal, SEXP optTimePeriod) {
  int n = LENGTH(inReal);
  double *restrict src = REAL(inReal);
  int period = INTEGER(optTimePeriod)[0];

  SEXP result = PROTECT(allocVector(REALSXP, n));
  double *rsi = REAL(result);

  int outBeg, outNb;
  // clang-format off
  TA_RetCode ret = TA_RSI(
    0, 
    n - 1, 
    src, 
    period, 
    &outBeg, 
    &outNb, 
    rsi
  );
  // clang-format on

  // shift
  shift_array(rsi, n, outBeg);

  UNPROTECT(1);
  return result;
}
