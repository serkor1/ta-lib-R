// Interface to ta_MACD (Moving Average Convergence/Divergence)
//
// Parameters
//   inReal         : numeric vector of source prices.
//   optFastPeriod  : integer, fast EMA period.
//   optSlowPeriod  : integer, slow EMA period.
//   optSignalPeriod: integer, signal‐line EMA period.
//
// Description
//   Computes the MACD line, its signal‐line, and the MACD histogram.
//   Returns an n × 3 matrix with columns "macd","signal","histogram".

#include "lib.h"
#include <R.h>
#include <Rinternals.h>
#include <ta_libc.h>

SEXP impl_ta_MACD(SEXP inReal, SEXP optFastPeriod, SEXP optSlowPeriod,
                  SEXP optSignalPeriod) {
  int n = LENGTH(inReal);
  double *restrict src = REAL(inReal);
  int fastP = INTEGER(optFastPeriod)[0];
  int slowP = INTEGER(optSlowPeriod)[0];
  int signalP = INTEGER(optSignalPeriod)[0];

  SEXP result = PROTECT(allocMatrix(REALSXP, n, 3));
  double *macd = REAL(result);
  double *signal = macd + n;
  double *histogram = macd + 2 * n;

  int outBeg, outNb;
  TA_RetCode ret =
      TA_MACD(0, n - 1, src, fastP, slowP, signalP, &outBeg, &outNb,
              macd + outBeg, signal + outBeg, histogram + outBeg);

  for (int i = 0; i < outBeg; ++i)
    macd[i] = signal[i] = histogram[i] = NA_REAL;
  for (int i = outBeg + outNb; i < n; ++i)
    macd[i] = signal[i] = histogram[i] = NA_REAL;

  SEXP dims = PROTECT(allocVector(VECSXP, 2));
  SEXP cnames = PROTECT(allocVector(STRSXP, 3));
  SET_STRING_ELT(cnames, 0, mkChar("macd"));
  SET_STRING_ELT(cnames, 1, mkChar("signal"));
  SET_STRING_ELT(cnames, 2, mkChar("histogram"));
  SET_VECTOR_ELT(dims, 0, R_NilValue);
  SET_VECTOR_ELT(dims, 1, cnames);
  setAttrib(result, R_DimNamesSymbol, dims);

  UNPROTECT(3);
  return result;
}
