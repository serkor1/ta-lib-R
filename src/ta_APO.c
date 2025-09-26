// Interface to ta_APO.c
//
// Parameters
//   inReal     : Numeric vector of input values.
//   fastPeriod : Integer, period for the fast moving average.
//   slowPeriod : Integer, period for the slow moving average.
//   maType     : Integer, TA-Lib MA type (e.g., SMA, EMA).
//
// Description
//   Computes the Absolute Price Oscillator (APO), i.e. the difference
//   between two moving averages of the input. Returns a numeric vector
//   of the same length as input; positions before the lookback are set to NA.
#include "MAType.h"
#include "lib.h"
#include "shift.h"
#include "ta_defs.h"
#include <Rinternals.h>
#include <ta_libc.h>

SEXP impl_ta_APO(SEXP inRealSEXP, SEXP fastPeriodSEXP, SEXP slowPeriodSEXP,
                 SEXP maTypeSEXP) {
  // Protect the output vector from garbage collection
  R_xlen_t n = xlength(inRealSEXP);
  int fastPeriod = asInteger(fastPeriodSEXP);
  int slowPeriod = asInteger(slowPeriodSEXP);
  TA_MAType maType = as_MAType(maTypeSEXP);

  // Allocate result vector
  SEXP outRealSEXP = PROTECT(allocVector(REALSXP, n));
  double *restrict outReal = REAL(outRealSEXP);
  const double *restrict inReal = REAL(inRealSEXP);

  // Call TA-Lib
  int outBegIdx = 0, outNBElement = 0;
  // clang-format off
  TA_RetCode ret = TA_APO(
    0,
    (int)n - 1,
    inReal,
    fastPeriod,
    slowPeriod,
    maType,
    &outBegIdx,
    &outNBElement,
    outReal 
  );
  // clang-format on

  if (ret != TA_SUCCESS) {
    UNPROTECT(1);
    error("TA_APO failed with error code %d", ret);
  }

  // shift
  shift_array(outReal, n, outBegIdx);

  UNPROTECT(1);
  return outRealSEXP;
}
