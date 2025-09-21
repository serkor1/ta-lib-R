// Interface to TA_AROONOSC (Aroon Oscillator)
//
// Parameters
//   high, low     : numeric vectors (same length)
//   timeperiod    : integer SEXP (typical default 14)
//
// Description
//   Returns a REALSXP vector of length n (down - up), padded with NA_REAL
//   for the initial lookback.

#include "R_ext/Error.h"
#include "Rinternals.h"
#include "lib.h"
#include "shift.h"
#include "ta_func.h"
#include "ta_libc.h"

// clang-format off
SEXP impl_ta_AROONOSC(
  SEXP high,
  SEXP low,
  SEXP timeperiod) {
  // clang-format on

  int protect_count = 0;

  const int n = LENGTH(high);
  const double *restrict high_ptr = REAL(high);
  const double *restrict low_ptr = REAL(low);
  const int period = INTEGER(timeperiod)[0];

  SEXP result = PROTECT(allocVector(REALSXP, n));
  protect_count++;
  double *restrict out_ptr = REAL(result);

  const int minimum_lookback = TA_AROONOSC_Lookback(period);

  if (n < minimum_lookback) {
    Rf_warning("Input length (%d) is smaller than required lookback (%d).", n,
               minimum_lookback);
    for (int i = 0; i < n; ++i)
      out_ptr[i] = NA_REAL;

  } else {
    int outBeg = 0, outNb = 0;

    // clang-format off
    TA_RetCode return_code = TA_AROONOSC(
      /*startIdx*/ 0,
      /*endIdx  */ n - 1,
      /*inHigh  */ high_ptr,
      /*inLow   */ low_ptr,
      /*optPer  */ period,
      /*outBeg  */ &outBeg,
      /*outNb   */ &outNb,
      /*outReal */ out_ptr
    );
    // clang-format on

    if (return_code != TA_SUCCESS) {
      UNPROTECT(protect_count);
      Rf_error("TA_AROONOSC failed: return code %d", return_code);
    }

    shift_array(out_ptr, n, outBeg);
  }

  UNPROTECT(protect_count);
  return result;
}
