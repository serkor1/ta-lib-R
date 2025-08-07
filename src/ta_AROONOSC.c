// Interface to ta_AROONOSC.c
//
// Parameters
//   inHigh     : Numeric vector of high prices.
//   inLow      : Numeric vector of low prices.
//   timePeriod : Integer, look-back period.
//
// Description
//   Computes the Aroon Oscillator (difference between AroonUp and
//   AroonDown). Returns a numeric vector of same length as input;
//   positions before lookback are NA.
#include "lib.h"
#include <R.h>
#include <Rinternals.h>
#include <ta_libc.h>

SEXP impl_ta_AROONOSC(SEXP inHighSEXP, SEXP inLowSEXP, SEXP timePeriodSEXP) {
  R_xlen_t n = xlength(inHighSEXP);
  if (xlength(inLowSEXP) != n)
    error("inHigh and inLow must have the same length");

  int timePeriod = asInteger(timePeriodSEXP);
  const double *restrict inHigh = REAL(inHighSEXP);
  const double *restrict inLow = REAL(inLowSEXP);

  // Allocate output vector
  SEXP outOscSEXP = PROTECT(allocVector(REALSXP, n));
  double *restrict outOsc = REAL(outOscSEXP);

  // Call TA-Lib
  int outBegIdx = 0, outNBElement = 0;
  TA_RetCode ret = TA_AROONOSC(0, (int)n - 1, inHigh, inLow, timePeriod,
                               &outBegIdx, &outNBElement, outOsc);
  if (ret != TA_SUCCESS) {
    UNPROTECT(1);
    error("TA_AROONOSC failed with error code %d", ret);
  }

  // Leading NAs
  for (int i = 0; i < outBegIdx; ++i)
    outOsc[i] = NA_REAL;

  // Shift valid outputs
  memmove(outOsc + outBegIdx, outOsc, (size_t)outNBElement * sizeof(double));

  // Trailing NAs
  for (int i = outBegIdx + outNBElement; i < n; ++i)
    outOsc[i] = NA_REAL;

  UNPROTECT(1);
  return outOscSEXP;
}
