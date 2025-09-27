// Interface to ta_HT_DCPERIOD (Hilbert Transform - Dominant Cycle Period)
//
// Parameters
//   inReal : numeric vector of source prices.
//
// Description
//   Returns the smoothed dominant cycle period per bar as a numeric vector.
//   Length equals input; leading elements are NA (padded using shift_array).
#include "lib.h"
#include "shift.h"
#include <R.h>
#include <Rinternals.h>
#include <ta_libc.h>

SEXP impl_ta_HT_DCPERIOD(SEXP inReal) {
  // 1) Basic sizes and raw pointers (use restrict for better aliasing
  // assumptions).
  const int n = LENGTH(inReal);
  double *restrict src = REAL(inReal);

  // 2) Allocate full-length output. We write at offset outBeg and then pad.
  SEXP result = PROTECT(allocVector(REALSXP, n));
  double *restrict out = REAL(result);

  // check wether the minimum
  // required matches that of
  // the input
  const int minimum_lookback = TA_HT_DCPERIOD_Lookback();
  if (n < minimum_lookback) {
    Rf_warning("Input length (%d) is smaller than required lookback (%d).", n,
               minimum_lookback);

    for (size_t i = 0; i < n; ++i) {
      out[i] = NA_REAL;
    }

    UNPROTECT(1);
    return result;
  }

  // 3) Call TA-Lib. We offset the output pointer by outBeg to avoid an extra
  // copy.
  int outBeg = 0, outNb = 0;
  // clang-format off
  TA_RetCode ret = TA_HT_DCPERIOD(
    0,
    n > 0 ? n - 1 : 0,
    src,
    &outBeg,
    &outNb,
    out + outBeg);
  // clang-format on

  // 4) Shift-pad in place so the first outBeg values become NA and length stays
  // n.
  //    This also covers ret != TA_SUCCESS by NA-padding the whole vector when
  //    outBeg>=n.
  shift_array(out, n, outBeg);

  UNPROTECT(1);
  return result;
}
