// Interface to ta_BBANDS (Bollinger Bands)
//
// Parameters
//   inReal         : numeric vector of source prices.
//   optTimePeriod  : integer, lookback period (e.g. 20).
//   optNbDevUp     : double, number of standard deviations for upper band.
//   optNbDevDn     : double, number of standard deviations for lower band.
//   optMAType      : integer code of TA_MAType (e.g. TA_MAType_SMA).
//
// Description
//   Computes the upper, middle, and lower Bollinger Bands over the input
//   series. Returns an n × 3 matrix (columns "upper","middle","lower")
//   padded with NA_REAL for values where the bands are undefined.

#include "MAType.h"
#include "lib.h"
#include "names.h"
#include "shift.h"
#include "ta-lib/include/ta_defs.h"
#include "ta_func.h"
#include <Rinternals.h>
#include <ta_libc.h>

// clang-format off
SEXP impl_ta_BBANDS(
  SEXP inReal, 
  SEXP optTimePeriod, 
  SEXP optNbDevUp,
  SEXP optNbDevDn, 
  SEXP optMAType) {
// clang-format on 

  int protect_count = 0;
  // determine MAs
  TA_MAType maType = as_MAType(optMAType);

  // periods and standard
  // deviations
  int period = INTEGER(optTimePeriod)[0];
  double nbUp = REAL(optNbDevUp)[0];
  double nbDn = REAL(optNbDevDn)[0];

  // data
  int n = LENGTH(inReal);
  double *restrict src = REAL(inReal);
  
  // clang-format off
  SEXP result = PROTECT(
    allocMatrix(REALSXP, n, 3)
  ); protect_count++;
  double *upper  = REAL(result);
  double *middle = upper + n;
  double *lower  = upper + 2 * n;
  // clang-format on

  // clang-format off
  const int minimum_lookback = TA_BBANDS_Lookback(
    period, 
    nbUp, 
    nbDn, 
    maType
  );
  // clang-format on

  if (n < minimum_lookback) {
    Rf_warning("Input length (%d) is smaller than required lookback (%d).", n,
               minimum_lookback);

    for (size_t i = 0; i < n; ++i) {
      upper[i] = middle[i] = lower[i] = NA_REAL;
    }

  } else {

    int outBeg = 0, outNb = 0;
    // clang-format off
    TA_RetCode return_code = TA_BBANDS(
      0, 
      n - 1, 
      src, 
      period, 
      nbUp, 
      nbDn, 
      maType, 
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

    // shift arrays
    shift_array(upper, n, outBeg);
    shift_array(middle, n, outBeg);
    shift_array(lower, n, outBeg);
  }

  // set column names
  // clang-format off
  set_colnames(
    result, 
    "upper", 
    "middle", 
    "lower"
  );
  // clang-format on

  UNPROTECT(protect_count);
  return result;
}
