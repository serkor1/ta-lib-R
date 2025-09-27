// Interface to ta_ULTOSC.c (Ultimate Oscillator)
//
// Parameters
//   high            – numeric vector of 'High' prices
//   low             – numeric vector of 'Low' prices
//   close           – numeric vector of 'Close' prices
//   timeperiod1     – integer SEXP for first lookback (e.g. 7)
//   timeperiod2     – integer SEXP for second lookback (e.g. 14)
//   timeperiod3     – integer SEXP for third lookback (e.g. 28)
//
// Description
//   Returns a numeric vector of the same length as inputs containing
//   the Ultimate Oscillator, with NA for indices before the lookback.
#include "lib.h"
#include "shift.h"
#include <R.h>
#include <Rinternals.h>
#include <ta_libc.h>

// clang-format off
SEXP impl_ta_ULTOSC(
  SEXP high, 
  SEXP low, 
  SEXP close, 
  SEXP timeperiod1,
  SEXP timeperiod2, 
  SEXP timeperiod3) {
  // clang-format on

  int protect_count = 0;

  // periods
  int p1 = INTEGER(timeperiod1)[0];
  int p2 = INTEGER(timeperiod2)[0];
  int p3 = INTEGER(timeperiod3)[0];

  // data
  int n = length(high);
  const double *__restrict__ high_ptr = REAL(high);
  const double *__restrict__ low_ptr = REAL(low);
  const double *__restrict__ close_ptr = REAL(close);

  int outBeg, outNB;
  // clang-format off
  SEXP output = PROTECT(
    allocVector(REALSXP, n)
  ); protect_count++;
  double *__restrict__ output_ptr = REAL(output);
  // clang-format on

  // clang-format off
  int minimum_lookback = TA_ULTOSC_Lookback(
    p1,
    p2,
    p3
  );
  // clang-format on

  if (n < minimum_lookback) {
    Rf_warning("Input length (%d) is smaller than required lookback (%d).", n,
               minimum_lookback);

    for (size_t i = 0; i < n; ++i) {
      output_ptr[i] = NA_REAL;
    }

  } else {

    // clang-format off
    TA_RetCode ret = TA_ULTOSC(
      0, 
      n - 1, 
      high_ptr , 
      low_ptr,   
      close_ptr, 
      p1, 
      p2, 
      p3,
      &outBeg, 
      &outNB, 
      output_ptr + outBeg
    );
    // clang-format on

    if (ret != TA_SUCCESS) {
      UNPROTECT(protect_count);
      error("TA_ULTOSC failed: return code %d", ret);
    }

    // shift
    shift_array(output_ptr, n, outBeg);
  }

  UNPROTECT(protect_count);
  return output;
}
