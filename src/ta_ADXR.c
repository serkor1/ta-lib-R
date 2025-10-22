// ta_ADXR.c
//
// Interface to ta_ADXR (Average Directional Movement Index Rating)
//
// Parameters
//   high : numeric vector of highs (double).
//   low  : numeric vector of lows  (double).
//   close: numeric vector of closes (double).
//   optTimePeriod : integer, period (default 14 in TA-Lib).
//
// Description
//   Computes ADXR over H/L/C. Returns a double vector of length n (unnamed),
//   padding the leading lookback with NA using shift_array(). We write results
//   at index 0 for cache-friendly contiguous stores, then shift once.
//
// Notes
//   - TA_ADXR_Lookback() includes the ADX dependency + unstable period.
//   - If n < lookback, we return all NA and warn.

#include "lib.h"
#include "names.h"
#include "shift.h"
#include "ta_func.h"
#include <R.h>
#include <Rinternals.h>
#include <ta_libc.h>

// clang-format off
SEXP impl_ta_ADXR(
    SEXP high, 
    SEXP low, 
    SEXP close, 
    SEXP optTimePeriod) {
// clang-format off
  int protect_count = 0;

  // period
  const int period = INTEGER(optTimePeriod)[0];

  // data
  const double *restrict high_ptr = REAL(high);
  const double *restrict low_ptr = REAL(low);
  const double *restrict close_ptr = REAL(close);

  int n = LENGTH(high);

  // clang-format off
  SEXP output = PROTECT(
    allocMatrix(REALSXP, n, 1)
  ); protect_count++;
  double *restrict output_ptr = REAL(output);
  // clang-format on

  const int minimum_lookback = TA_ADXR_Lookback(period);

  if (n < minimum_lookback) {
    Rf_warning("Input length (%d) is smaller than required lookback (%d).", n,
               minimum_lookback);

    for (size_t i = 0; i < n; ++i) {
      output_ptr[i] = NA_REAL;
    }

  } else {

    int outBeg = 0, outNb = 0;
    // clang-format off
    TA_RetCode return_code = TA_ADXR(
        0, 
        n - 1, 
        high_ptr, 
        low_ptr, 
        close_ptr, 
        period, 
        &outBeg, 
        &outNb,
        output_ptr
    );
    // clang-format on

    if (return_code != TA_SUCCESS) {
      UNPROTECT(protect_count);
      Rf_error("TA_ADXE failed with error code %d", return_code);
    }

    set_colnames(output, "ADXR");
    shift_array(output_ptr, n, outBeg);
  }

  UNPROTECT(protect_count);
  return output;
}
