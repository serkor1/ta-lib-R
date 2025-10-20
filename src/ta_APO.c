// Interface to ta_APO.c
//
// Parameters
//   x     : Numeric vector of input values.
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
#include "names.h"
#include "shift.h"
#include "ta_defs.h"
#include <Rinternals.h>
#include <ta_libc.h>

// clang-format off
SEXP impl_ta_APO(
  SEXP x_input, 
  SEXP fast_period, 
  SEXP slow_period,
  SEXP ma_type) {
  // clang-format on

  // Protect the output vector from garbage collection
  R_xlen_t n = xlength(x_input);
  int fastPeriod = asInteger(fast_period);
  int slowPeriod = asInteger(slow_period);
  TA_MAType maType = as_MAType(ma_type);

  // Allocate result vector
  SEXP result = PROTECT(allocMatrix(REALSXP, n, 1));
  double *restrict out = REAL(result);
  const double *restrict x = REAL(x_input);

  // Call TA-Lib
  int outBegIdx = 0, outNBElement = 0;
  // clang-format off
  TA_RetCode return_code = TA_APO(
    0,
    n - 1,
    x,
    fastPeriod,
    slowPeriod,
    maType,
    &outBegIdx,
    &outNBElement,
    out 
  );
  // clang-format on

  if (return_code != TA_SUCCESS) {
    UNPROTECT(1);
    error("TA_APO failed with error code %d", return_code);
  }

  // shift
  shift_array(out, n, outBegIdx);

  set_colnames(result, "APO");
  UNPROTECT(1);
  return result;
}
