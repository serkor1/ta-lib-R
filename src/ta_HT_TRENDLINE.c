// Interface to ta_HT_TRENDLINE (Hilbert Transform - Instantaneous Trendline)
//
// Parameters
//   inReal : numeric vector of source prices.
//
// Description
//   Returns the instantaneous trendline as a numeric vector.
//   Length equals input; leading elements are NA (padded using shift_array).
#include "R_ext/Arith.h"
#include "R_ext/Error.h"
#include "R_ext/Print.h"
#include "lib.h"
#include "shift.h"
#include <R.h>
#include <Rinternals.h>
#include <stdio.h>
#include <ta_libc.h>

SEXP impl_ta_HT_TRENDLINE(SEXP inReal) {
  const int n = LENGTH(inReal);
  double *restrict src = REAL(inReal);

  SEXP result = PROTECT(allocVector(REALSXP, n));
  double *restrict out = REAL(result);

  // check wether the minimum
  // required matches that of
  // the input
  const int minimum_lookback = TA_HT_TRENDLINE_Lookback();
  if (n < minimum_lookback) {
    Rf_warning("Input length (%d) is smaller than required lookback (%d).", n,
               minimum_lookback);

    for (size_t i = 0; i < n; ++i) {
      out[i] = NA_REAL;
    }

    UNPROTECT(1);
    return result;
  }

  int outBeg = 0, outNb = 0;
  // clang-format off
  TA_RetCode ret = TA_HT_TRENDLINE(
    0,
    n > 0 ? n - 1 : 0,
    src,
    &outBeg,
    &outNb,
    out + outBeg);
  // clang-format on

  // shift
  shift_array(out, n, outBeg);

  UNPROTECT(1);
  return result;
}
