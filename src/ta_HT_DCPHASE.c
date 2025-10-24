// Interface to ta_HT_DCPHASE (Hilbert Transform - Dominant Cycle Phase)
//
// Parameters
//   inReal : numeric vector of source prices.
//
// Description
//   Returns dominant cycle phase (degrees) as a numeric vector.
//   Length equals input; leading elements are NA (padded using shift_array).
#include "lib.h"
#include "names.h"
#include "shift.h"
#include <R.h>
#include <Rinternals.h>
#include <ta_libc.h>

SEXP impl_ta_HT_DCPHASE(SEXP inReal) {
  const int n = LENGTH(inReal);
  double *restrict src = REAL(inReal);

  SEXP result = PROTECT(allocMatrix(REALSXP, n, 1));
  double *restrict out = REAL(result);

  // check wether the minimum
  // required matches that of
  // the input
  const int minimum_lookback = TA_HT_DCPHASE_Lookback();
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
  TA_RetCode ret = TA_HT_DCPHASE(
    0,
    n > 0 ? n - 1 : 0,
    src,
    &outBeg,
    &outNb,
    out + outBeg);
  // clang-format on

  set_colnames(result, "DCPHASE");
  shift_array(out, n, outBeg);

  UNPROTECT(1);
  return result;
}
