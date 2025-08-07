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
#include "lib.h"
#include <R.h>
#include <Rinternals.h>
#include <ta_libc.h>

SEXP impl_ta_APO(SEXP inRealSEXP, SEXP fastPeriodSEXP, SEXP slowPeriodSEXP,
                 SEXP maTypeSEXP) {
  // Protect the output vector from garbage collection
  R_xlen_t n = xlength(inRealSEXP);
  int fastPeriod = asInteger(fastPeriodSEXP);
  int slowPeriod = asInteger(slowPeriodSEXP);
  int maType = asInteger(maTypeSEXP);

  // Allocate result vector
  SEXP outRealSEXP = PROTECT(allocVector(REALSXP, n));
  double *restrict outReal = REAL(outRealSEXP);
  const double *restrict inReal = REAL(inRealSEXP);

  // Call TA-Lib
  int outBegIdx = 0, outNBElement = 0;
  TA_RetCode ret = TA_APO(0,             // start index
                          (int)n - 1,    // end index
                          inReal,        // input array
                          fastPeriod,    // fast MA period
                          slowPeriod,    // slow MA period
                          maType,        // MA type
                          &outBegIdx,    // first valid output index
                          &outNBElement, // number of elements computed
                          outReal        // output array (length ≥ n)
  );
  if (ret != TA_SUCCESS) {
    UNPROTECT(1);
    error("TA_APO failed with error code %d", ret);
  }

  // Initialize first outBegIdx values to NA
  for (int i = 0; i < outBegIdx; ++i)
    outReal[i] = NA_REAL;

  // Shift valid outputs into place
  memmove(outReal + outBegIdx, outReal, (size_t)outNBElement * sizeof(double));

  // Fill trailing values with NA
  for (int i = outBegIdx + outNBElement; i < n; ++i)
    outReal[i] = NA_REAL;

  UNPROTECT(1);
  return outRealSEXP;
}
