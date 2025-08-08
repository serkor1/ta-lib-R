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
#include "shift.h"
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
  // clang-format off
  TA_RetCode ret = TA_AROONOSC(
    0, 
    (int)n - 1, 
    inHigh, 
    inLow, 
    timePeriod,
    &outBegIdx, 
    &outNBElement, 
    outOsc
  );
  // clang-format on

  if (ret != TA_SUCCESS) {
    UNPROTECT(1);
    error("TA_AROONOSC failed with error code %d", ret);
  }

  // shift
  shift_array(outOsc, n, outBegIdx);

  UNPROTECT(1);
  return outOscSEXP;
}
