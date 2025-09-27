// Interface to ta_MACD (Moving Average Convergence/Divergence)
//
// Parameters
//   x         : numeric vector of source prices.
//   optFastPeriod  : integer, fast EMA period.
//   optSlowPeriod  : integer, slow EMA period.
//   optSignalPeriod: integer, signal‐line EMA period.
//
// Description
//   Computes the MACD line, its signal‐line, and the MACD histogram.
//   Returns an n × 3 matrix with columns "macd","signal","histogram".

#include "lib.h"
#include "names.h"
#include "shift.h"
#include <R.h>
#include <Rinternals.h>
#include <ta_libc.h>

// clang-format off
SEXP impl_ta_MACD(
  SEXP x, 
  SEXP optFastPeriod, 
  SEXP optSlowPeriod,
  SEXP optSignalPeriod) {
  // clang-format on

  int protect_count = 0;
  // periods
  int fastP = INTEGER(optFastPeriod)[0];
  int slowP = INTEGER(optSlowPeriod)[0];
  int signalP = INTEGER(optSignalPeriod)[0];

  // data
  int n = LENGTH(x);
  double *restrict series = REAL(x);

  // clang-format off
  SEXP output = PROTECT(
    allocMatrix(REALSXP, n, 3)
  ); protect_count++;
  double *macd = REAL(output);
  double *signal = macd + n;
  double *histogram = macd + 2 * n;
  // clang-format on

  // clang-format off
  const int minimum_lookback = TA_MACD_Lookback(
    fastP, 
    slowP, 
    signalP
  );
  // clang-format on

  if (n < minimum_lookback) {
    Rf_warning("Input length (%d) is smaller than required lookback (%d).", n,
               minimum_lookback);

    for (size_t i = 0; i < n; ++i) {
      macd[i] = signal[i] = histogram[i] = NA_REAL;
    }

  } else {
    int outBeg = 0, outNb = 0;
    // clang-format off
    TA_RetCode return_code = TA_MACD(
      0, 
      n - 1,
      series, 
      fastP, 
      slowP, 
      signalP, 
      &outBeg,
      &outNb,
      macd + outBeg, 
      signal + outBeg, 
      histogram + outBeg
    );
    // clang-format on

    if (return_code != TA_SUCCESS) {
      UNPROTECT(protect_count);
      Rf_error("Failed with error code %d", return_code);
    }

    // shift
    shift_array(macd, n, outBeg);
    shift_array(signal, n, outBeg);
    shift_array(histogram, n, outBeg);
  }

  // set column names
  // clang-format off
  set_colnames(
    output, 
    "macd", 
    "signal", 
    "histogram"
  );
  // clang-format on

  UNPROTECT(protect_count);
  return output;
}
