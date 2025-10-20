// Interface to ta_ACCBANDS (Acceleration Bands)
//
// Parameters
//   inHigh         : numeric vector of high prices.
//   inLow          : numeric vector of low prices.
//   inClose        : numeric vector of close prices.
//   optTimePeriod  : integer, lookback period (From 2 to 100000).
//
// Description
//   Computes acceleration bands (upper, middle, lower) over the input series.
//   Returns an n × 3 matrix with columns "upper","middle","lower", padded
//   with NA_REAL where the bands are undefined.
//
// Implementation
//
// The function does not check for equal size of the
// of the input vectors. This is on the user.
//
// It uses lookback function to verify the validity
// of input vs lookback. If its invalid, it returns
// a warning with a NA_REAL padded matrix.

#include "R_ext/Error.h"
#include "lib.h"
#include "names.h"
#include "shift.h"
#include "ta_func.h"
#include <R.h>
#include <Rinternals.h>
#include <ta_libc.h>

// clang-format off
SEXP impl_ta_ACCBANDS(
  SEXP inHigh, 
  SEXP inLow, 
  SEXP inClose,
  SEXP optTimePeriod) {
  // clang-format on

  int protect_count = 0;
  int n = LENGTH(inHigh);
  double *restrict highs = REAL(inHigh);
  double *restrict lows = REAL(inLow);
  double *restrict closes = REAL(inClose);
  int period = INTEGER(optTimePeriod)[0];

  SEXP result = PROTECT(allocMatrix(REALSXP, n, 3));
  double *upper = REAL(result);
  double *middle = upper + n;
  double *lower = upper + 2 * n;
  protect_count++;

  // check minimum lookback
  const int minimum_lookback = TA_ACCBANDS_Lookback(period);
  if (n < minimum_lookback) {
    Rf_warning("Input length (%d) is smaller than required lookback (%d).", n,
               minimum_lookback);

    for (size_t i = 0; i < n; ++i) {
      upper[i] = middle[i] = lower[i] = NA_REAL;
    }

  } else {

    int outBeg = 0, outNb = 0;
    // clang-format off
    TA_RetCode return_code = TA_ACCBANDS(
      0, 
      n - 1, 
      highs, 
      lows, 
      closes, 
      period, 
      &outBeg, 
      &outNb,
      upper + outBeg,
      middle + outBeg,
      lower + outBeg
    );
    // clang-format on

    if (return_code != TA_SUCCESS) {
      UNPROTECT(protect_count);
      Rf_error("Failed with error code %d", return_code);
    }

    shift_array(upper, n, outBeg);
    shift_array(middle, n, outBeg);
    shift_array(lower, n, outBeg);
  }

  // set column names
  // clang-format off
  set_colnames(
    result, 
    "lower", 
    "middle", 
    "upper"
  );
  // clang-format on

  UNPROTECT(protect_count);
  return result;
}
