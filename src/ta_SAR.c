// Interface to TA_SAR (Parabolic SAR)
//
// Parameters
//   high, low        : numeric vectors (same length)
//   acceleration     : numeric scalar (double), step (e.g., 0.02)
//   maximum          : numeric scalar (double), max step (e.g., 0.2)
//
// Description
//   Returns a numeric vector of length n, padded with NA_REAL for the initial
//   lookback, then SAR values thereafter.

#include "R_ext/Error.h"
#include "Rinternals.h"
#include "lib.h"
#include "shift.h"
#include <ta_libc.h>

// clang-format off
SEXP impl_ta_SAR(
  SEXP high,
  SEXP low,
  SEXP acceleration,
  SEXP maximum) {
  // clang-format on

  int protect_count = 0;

  const int n = LENGTH(high);
  const double *restrict high_ptr = REAL(high);
  const double *restrict low_ptr = REAL(low);
  const double acc = REAL(acceleration)[0];
  const double maxv = REAL(maximum)[0];

  SEXP result = PROTECT(allocVector(REALSXP, n));
  protect_count++;
  double *restrict out_ptr = REAL(result);

  const int minimum_lookback = TA_SAR_Lookback(acc, maxv);

  if (n < minimum_lookback) {
    Rf_warning("Input length (%d) is smaller than required lookback (%d).", n,
               minimum_lookback);
    for (int i = 0; i < n; ++i)
      out_ptr[i] = NA_REAL;

  } else {
    int outBeg = 0, outNb = 0;

    // clang-format off
    TA_RetCode rc = TA_SAR(
      /*startIdx*/ 0,
      /*endIdx  */ n - 1,
      /*inHigh  */ high_ptr,
      /*inLow   */ low_ptr,
      /*accel   */ acc,
      /*maximum */ maxv,
      /*outBeg  */ &outBeg,
      /*outNb   */ &outNb,
      /*outReal */ out_ptr
    );
    // clang-format on

    if (rc != TA_SUCCESS) {
      UNPROTECT(protect_count);
      Rf_error("TA_SAR failed: return code %d", rc);
    }

    shift_array(out_ptr, n, outBeg);
  }

  UNPROTECT(protect_count);
  return result;
}
