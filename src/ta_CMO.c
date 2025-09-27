// ta_CMO.c
//
// Interface to ta_CMO (Chande Momentum Oscillator)
//
// Parameters
//   x            : numeric vector (double).
//   optTimePeriod: integer, period (default 14 in TA-Lib).
//
// Description
//   Computes CMO on a single price stream. Returns a double vector of length n
//   (unnamed), with the first lookback elements padded by NA using
//   shift_array().

#include "lib.h"
#include "shift.h"
#include <R.h>
#include <Rinternals.h>
#include <ta_libc.h>

SEXP impl_ta_CMO(SEXP x, SEXP optTimePeriod) {
  // protection counter
  int protection_count = 0;

  // values
  int n = length(x);
  int lag = INTEGER(optTimePeriod)[0];
  int outBeg = 0, outNb = 0;

  // data
  const double *__restrict__ x_ptr = REAL(x);

  // output vector
  // clang-format off
  SEXP output = PROTECT(
    allocVector(REALSXP, n)
  ); protection_count++;
  double *output_ptr = REAL(output);
  // clang-format on

  // clang-format off
  const int minimum_lookback = TA_CMO_Lookback(
    lag
  );
  // clang-format on

  if (n < minimum_lookback) {
    Rf_warning("Input length (%d) is smaller than required lookback (%d).", n,
               minimum_lookback);

    for (size_t i = 0; i < n; ++i) {
      output_ptr[i] = NA_REAL;
    }

  } else {

    int outBeg = 0, outNb = 0;
    // clang-format off
    TA_RetCode return_code = TA_CMO(
        0, 
        n-1, 
        x_ptr, 
        lag, 
        &outBeg, 
        &outNb, 
        output_ptr
    );
    // clang-format on

    if (return_code != TA_SUCCESS) {
      UNPROTECT(protection_count);
      Rf_error("ta_CMO failed: return code %d", return_code);
    }

    // shift values
    shift_array(output_ptr, n, outBeg);
  }

  UNPROTECT(protection_count);
  return output;
}
