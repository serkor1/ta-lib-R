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
#include "shift.h"
#include <Rinternals.h>
#include <ta_libc.h>

SEXP impl_ta_MACDEXT(SEXP inReal, SEXP optFastPeriod, SEXP optFastMAType,
                     SEXP optSlowPeriod, SEXP optSlowMAType,
                     SEXP optSignalPeriod, SEXP optSignalMAType) {
  // 1) Prepare inputs
  int n = LENGTH(inReal);
  const double *restrict src = REAL(inReal);
  int fastP = INTEGER(optFastPeriod)[0];
  TA_MAType fastT = as_MAType(optFastMAType);
  int slowP = INTEGER(optSlowPeriod)[0];
  TA_MAType slowT = as_MAType(optSlowMAType);
  int signalP = INTEGER(optSignalPeriod)[0];
  TA_MAType signalT = as_MAType(optSignalMAType);

  // 2) Allocate output matrix (n rows × 3 cols)
  SEXP result = PROTECT(allocMatrix(REALSXP, n, 3));
  double *restrict macd = REAL(result);
  double *restrict signal = macd + n;
  double *restrict histogram = macd + 2 * n;

  // 3) Call underlying TA function
  int outBeg, outNb;
  // clang-format off
  TA_RetCode ret = TA_MACDEXT(
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

  if (ret != TA_SUCCESS) {
    UNPROTECT(1);
    error("TA_MACDEXT failed with code %d", ret);
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
