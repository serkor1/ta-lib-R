// ta_ADX.c
//
// Interface to ta_ADX (Average Directional Movement Index)
//
// Parameters
//   high : numeric vector of highs (double).
//   low  : numeric vector of lows  (double).
//   close: numeric vector of closes (double).
//   optTimePeriod : integer, period (default 14 in TA-Lib).
//
// Description
//   Computes ADX over H/L/C. Returns a double vector of length n (unnamed),
//   with the first lookback elements padded by NA using shift_array().

#include "Rdefines.h"
#include "lib.h"
#include "names.h"
#include "shift.h"
#include "ta_func.h"
#include <R.h>
#include <Rinternals.h>
#include <ta_libc.h>

// clang-format off
SEXP impl_ta_ADX(
    SEXP high, 
    SEXP low, 
    SEXP close, 
    SEXP optTimePeriod) {
  // clang-format on

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

  const int minimum_lookback = TA_ADX_Lookback(period);

  if (n < minimum_lookback) {
    Rf_warning("Input length (%d) is smaller than required lookback (%d).", n,
               minimum_lookback);

    for (size_t i = 0; i < n; ++i) {
      output_ptr[i] = NA_REAL;
    }

  } else {

    int outBeg = 0, outNb = 0;
    // clang-format off
    TA_RetCode return_code = TA_ADX(
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
      Rf_error("TA_ADX failed with error code %d", return_code);
    }

    set_colnames(output, "ADX");
    shift_array(output_ptr, n, outBeg);
  }

  UNPROTECT(protect_count);
  return output;
}
