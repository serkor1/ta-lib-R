// Interface to TA_MFI (Money Flow Index)
//
// Parameters
//   high, low, close : numeric vectors (same length)
//   volume           : numeric vector of volumes
//   timeperiod       : integer SEXP for lookback (typical default 14)
//
// Description
//   Returns an MFI numeric vector of length n in [0,100], padded with NA_REAL
//   for the first lookback samples.

#include "R_ext/Error.h"
#include "Rinternals.h"
#include "lib.h"
#include "names.h"
#include "shift.h"
#include <ta_libc.h>

// clang-format off
SEXP impl_ta_MFI(
  SEXP high,
  SEXP low,
  SEXP close,
  SEXP volume,
  SEXP timeperiod) {
  // clang-format on

  int protect_count = 0;

  const int n = LENGTH(high);
  const double *restrict high_ptr = REAL(high);
  const double *restrict low_ptr = REAL(low);
  const double *restrict close_ptr = REAL(close);
  const double *restrict volume_ptr = REAL(volume);
  const int period = INTEGER(timeperiod)[0];

  SEXP result = PROTECT(allocMatrix(REALSXP, n, 1));
  protect_count++;
  double *restrict out_ptr = REAL(result);

  const int minimum_lookback = TA_MFI_Lookback(period);

  if (n < minimum_lookback) {
    Rf_warning("Input length (%d) is smaller than required lookback (%d).", n,
               minimum_lookback);
    for (int i = 0; i < n; ++i)
      out_ptr[i] = NA_REAL;

  } else {
    int outBeg = 0, outNb = 0;

    TA_RetCode rc = TA_MFI(
        /*startIdx*/ 0,
        /*endIdx  */ n - 1,
        /*inHigh  */ high_ptr,
        /*inLow   */ low_ptr,
        /*inClose */ close_ptr,
        /*inVol   */ volume_ptr,
        /*optPer  */ period,
        /*outBeg  */ &outBeg,
        /*outNb   */ &outNb,
        /*outReal */ out_ptr);

    if (rc != TA_SUCCESS) {
      UNPROTECT(protect_count);
      Rf_error("TA_MFI failed: return code %d", rc);
    }

    // Align to full length
    shift_array(out_ptr, n, outBeg);
    set_colnames(result, "MFI");
  }

  UNPROTECT(protect_count);
  return result;
}
