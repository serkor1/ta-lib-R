// ta_MACDEXT.c
// Interface to TA-Lib’s TA_MACDEXT (MACD with controllable MA types)
//
// Parameters
//   inReal          : numeric vector of source prices (length n).
//   optFastPeriod   : integer, fast MA period.
//   optFastMAType   : integer MAType code for fast MA.
//   optSlowPeriod   : integer, slow MA period.
//   optSlowMAType   : integer MAType code for slow MA.
//   optSignalPeriod : integer, signal MA period.
//   optSignalMAType : integer MAType code for signal MA.
//
// Description
//   Computes MACD line, its signal line, and the MACD histogram
//   with user-specified moving average types. Returns an n×3 matrix
//   with columns "macd", "signal", "histogram" (all lower-case).

#include "MAType.h"
#include "lib.h"
#include "names.h"
#include "shift.h"
#include "ta_func.h"
#include <Rinternals.h>
#include <ta_libc.h>

// clang-format off
SEXP impl_ta_MACDEXT(
  SEXP inReal, 
  SEXP optFastPeriod, 
  SEXP optFastMAType,
  SEXP optSlowPeriod, 
  SEXP optSlowMAType,
  SEXP optSignalPeriod, 
  SEXP optSignalMAType) {
  // clang-format on

  int protect_count = 0;

  // determine MAs
  TA_MAType fastT = as_MAType(optFastMAType);
  TA_MAType slowT = as_MAType(optSlowMAType);
  TA_MAType signalT = as_MAType(optSignalMAType);

  // periods
  int fastP = INTEGER(optFastPeriod)[0];
  int slowP = INTEGER(optSlowPeriod)[0];
  int signalP = INTEGER(optSignalPeriod)[0];

  // data
  int n = LENGTH(inReal);
  const double *restrict src = REAL(inReal);

  // clang-format off
  SEXP result = PROTECT(
    allocMatrix(REALSXP, n, 3)
  ); protect_count++;
  double *restrict macd = REAL(result);
  double *restrict signal = macd + n;
  double *restrict histogram = macd + 2 * n;
  // clang-format on

  // clang-format off
  const int minimum_lookback = TA_MACDEXT_Lookback(
    fastP, 
    fastT, 
    slowP, 
    slowT, 
    signalP, 
    signalT
  );
  // clang-format on

  if (n < minimum_lookback) {
    Rf_warning("Input length (%d) is smaller than required lookback (%d).", n,
               minimum_lookback);

    for (size_t i = 0; i < n; ++i) {
      macd[i] = signal[i] = histogram[i] = NA_REAL;
    }

  } else {

    int outBeg, outNb;
    // clang-format off
    TA_RetCode return_code = TA_MACDEXT(
      0,  
      n - 1,
      src,
      fastP, 
      fastT,
      slowP, 
      slowT, 
      signalP, 
      signalT, 
      &outBeg, 
      &outNb, 
      macd + outBeg,
      signal + outBeg, 
      histogram + outBeg
    );
    // clang-format on

    if (return_code != TA_SUCCESS) {
      UNPROTECT(1);
      error("TA_MACDEXT failed with code %d", return_code);
    }

    // 4) Shift each output down by outBeg, padding with NA
    shift_array(macd, n, outBeg);
    shift_array(signal, n, outBeg);
    shift_array(histogram, n, outBeg);
  }

  // set column names
  // clang-format off
  set_colnames(
    result, 
    "macd", 
    "signal", 
    "histogram"
  );
  // clang-format on

  UNPROTECT(protect_count);
  return result;
}
