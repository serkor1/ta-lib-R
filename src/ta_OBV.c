// Interface to TA_OBV (On-Balance Volume)
//
// Parameters
//   close  : numeric vector of close prices
//   volume : numeric vector of volumes (same length as close)
//
// Description
//   Computes on-balance volume. Returns a numeric vector of length n,
//   padded with NA_REAL for the initial lookback (usually zero for OBV).

#include "R_ext/Error.h"
#include "Rinternals.h"
#include "lib.h"
#include "shift.h"
#include "ta_func.h"
#include "ta_libc.h"

// clang-format off
SEXP impl_ta_OBV(
  SEXP close,
  SEXP volume) {
  // clang-format on

  int protect_count = 0;

  const int n = LENGTH(close);
  const double *restrict close_ptr = REAL(close);
  const double *restrict volume_ptr = REAL(volume);

  SEXP result = PROTECT(allocVector(REALSXP, n));
  protect_count++;
  double *restrict out_ptr = REAL(result);

  const int minimum_lookback = TA_OBV_Lookback();

  if (n < minimum_lookback) {
    Rf_warning("Input length (%d) is smaller than required lookback (%d).", n,
               minimum_lookback);
    for (int i = 0; i < n; ++i)
      out_ptr[i] = NA_REAL;

  } else {
    int outBeg = 0, outNb = 0;

    TA_RetCode rc = TA_OBV(
        /*startIdx*/ 0,
        /*endIdx  */ n - 1,
        /*inReal  */ close_ptr,
        /*inVol   */ volume_ptr,
        /*outBeg  */ &outBeg,
        /*outNb   */ &outNb,
        /*outReal */ out_ptr);

    if (rc != TA_SUCCESS) {
      UNPROTECT(protect_count);
      Rf_error("TA_OBV failed: return code %d", rc);
    }

    // Align to full length
    shift_array(out_ptr, n, outBeg);
  }

  UNPROTECT(protect_count);
  return result;
}
