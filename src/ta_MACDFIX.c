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
#include "MAType.h"
#include "lib.h"
#include "shift.h"
#include <R.h>
#include <Rinternals.h>
#include <ta_libc.h>

SEXP impl_ta_MACDFIX(SEXP inReal, SEXP optSignalPeriod) {
  // 1) Prepare inputs
  int n = LENGTH(inReal);
  const double *restrict src = REAL(inReal);
  int signalP = INTEGER(optSignalPeriod)[0];

  // 2) Allocate output matrix (n rows × 3 cols)
  SEXP result = PROTECT(allocMatrix(REALSXP, n, 3));
  double *restrict macd = REAL(result);
  double *restrict signal = macd + n;
  double *restrict histogram = macd + 2 * n;

  // 3) Call underlying TA function
  int outBeg, outNb;
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

  // 5) Attach column names
  SEXP dimnames = PROTECT(allocVector(VECSXP, 2));
  SEXP cnames = PROTECT(allocVector(STRSXP, 3));
  SET_STRING_ELT(cnames, 0, mkChar("macd"));
  SET_STRING_ELT(cnames, 1, mkChar("signal"));
  SET_STRING_ELT(cnames, 2, mkChar("histogram"));
  SET_VECTOR_ELT(dimnames, 0, R_NilValue);
  SET_VECTOR_ELT(dimnames, 1, cnames);
  setAttrib(result, R_DimNamesSymbol, dimnames);

  UNPROTECT(3);
  return result;
}
