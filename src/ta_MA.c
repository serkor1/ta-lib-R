// Interface to TA_MA (moving average)
//
// Parameters
//   real            – numeric vector of inputs
//   lag      – integer SEXP for MA period (1 to 100000)
//   matype          – integer SEXP for MAType (0=SMA … 8=T3)
//
// Description
//   Returns a numeric vector of the same length as `real`,
//   with NA_REAL for the first lookback samples, then the
//   moving‐average values thereafter.
#include "MAType.h"
#include "R_ext/Error.h"
#include "lib.h"
#include "shift.h"
#include <Rinternals.h>
#include <ta_libc.h>

// clang-format off
SEXP impl_ta_MA(
  SEXP x, 
  SEXP period, 
  SEXP matype) {
  // clang-format on

  // protection counter
  int protection_count = 0;

  // moving average
  TA_MAType MAType = as_MAType(matype);

  // values
  int n = length(x);
  int lag = INTEGER(period)[0];
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
  const int minimum_lookback = TA_MA_Lookback(
    lag, 
    MAType
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
    TA_RetCode return_code = TA_MA(
      0, 
      n - 1, 
      x_ptr, 
      lag, 
      MAType, 
      &outBeg, 
      &outNb, 
      output_ptr
    );
    // clang-format on

    if (return_code != TA_SUCCESS) {
      UNPROTECT(protection_count);
      Rf_error("TA_MA failed: return code %d", return_code);
    }

    // shift values
    shift_array(output_ptr, n, outBeg);
  }

  UNPROTECT(protection_count);
  return output;
}