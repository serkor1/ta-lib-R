// Interface to ta_HT_TRENDMODE (Hilbert Transform - Trend vs Cycle Mode)
//
// Parameters
//   inReal : numeric vector of source prices.
//
// Description
//   Returns an integer vector (0 = cycle mode, 1 = trend mode) per bar.
//   Length equals input; leading elements are NA_INTEGER (padded via
//   shift_array).
#include "R_ext/Arith.h"
#include "lib.h"
#include "shift.h"
#include "ta_func.h"
#include <R.h>
#include <Rinternals.h>
#include <ta_libc.h>

SEXP impl_ta_HT_TRENDMODE(SEXP inReal) {
  const int n = LENGTH(inReal);
  double *restrict src = REAL(inReal);

  // Integer vector because TA_HT_TRENDMODE outputs int[ ].
  SEXP result = PROTECT(allocVector(INTSXP, n));
  int *restrict out = INTEGER(result);

  // check wether the minimum
  // required matches that of
  // the input
  const int minimum_lookback = TA_HT_TRENDMODE_Lookback();
  if (n < minimum_lookback) {
    Rf_warning("Input length (%d) is smaller than required lookback (%d).", n,
               minimum_lookback);

    for (size_t i = 0; i < n; ++i) {
      out[i] = NA_INTEGER;
    }

    UNPROTECT(1);
    return result;
  }

  int outBeg = 0, outNb = 0;
  // clang-format off
  TA_RetCode ret = TA_HT_TRENDMODE(
    0,
    n > 0 ? n - 1 : 0,
    src,
    &outBeg,
    &outNb,
    out + outBeg);
  // clang-format on

  // Pad with NA_INTEGER for the leading lookback window.
  shift_array(out, n, outBeg);

  UNPROTECT(1);
  return result;
}
