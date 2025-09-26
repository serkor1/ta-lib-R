// ta_MACDFIX.c
// Interface to TA-Lib’s TA_MACDFIX (MACD fixed 12/26)
//
// Parameters
//   inReal          : numeric vector of source prices (length n).
//   optSignalPeriod : integer, signal MA period.
//
// Description
//   Computes MACD line (EMA12–EMA26), its signal line, and the histogram
//   using the fixed 12/26 EMA and user-specified signal period. Returns
//   an n×3 matrix with columns "macd", "signal", "histogram".
#include "lib.h"
#include "names.h"
#include "shift.h"
#include "ta_func.h"
#include <R.h>
#include <Rinternals.h>
#include <ta_libc.h>

SEXP impl_ta_MACDFIX(SEXP inReal, SEXP optSignalPeriod) {
  int protect_count = 0;
  // 1) Prepare inputs
  int n = LENGTH(inReal);
  const double *restrict src = REAL(inReal);
  int signalP = INTEGER(optSignalPeriod)[0];

  // 2) Allocate output matrix (n rows × 3 cols)
  SEXP result = PROTECT(allocMatrix(REALSXP, n, 3));
  double *restrict macd = REAL(result);
  double *restrict signal = macd + n;
  double *restrict histogram = macd + 2 * n;

  const int minimum_lookback = TA_MACDFIX_Lookback(signalP);
  if (n < minimum_lookback) {
    Rf_warning("Input length (%d) is smaller than required lookback (%d).", n,
               minimum_lookback);

    for (size_t i = 0; i < n; ++i) {
      macd[i] = signal[i] = histogram[i] = NA_REAL;
    }
  } else {
    // 3) Call underlying TA function
    int outBeg = 0, outNb = 0;
    // clang-format off
  TA_RetCode ret = TA_MACDFIX(
    0,
    n - 1,
    src,
    signalP,
    &outBeg, 
    &outNb, 
    macd + outBeg, 
    signal + outBeg,
    histogram + outBeg
  );
    // clang-format on

    if (ret != TA_SUCCESS) {
      UNPROTECT(1);
      error("TA_MACDFIX failed with code %d", ret);
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
