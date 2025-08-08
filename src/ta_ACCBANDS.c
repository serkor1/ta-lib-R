// Interface to ta_ACCBANDS (Acceleration Bands)
//
// Parameters
//   inHigh         : numeric vector of high prices.
//   inLow          : numeric vector of low prices.
//   inClose        : numeric vector of close prices.
//   optTimePeriod  : integer, lookback period (From 2 to 100000).
//
// Description
//   Computes acceleration bands (upper, middle, lower) over the input series.
//   Returns an n × 3 matrix with columns "upper","middle","lower", padded
//   with NA_REAL where the bands are undefined.

#include "lib.h"
#include "shift.h"
#include <R.h>
#include <Rinternals.h>
#include <ta_libc.h>

SEXP impl_ta_ACCBANDS(SEXP inHigh, SEXP inLow, SEXP inClose,
                      SEXP optTimePeriod) {

  int n = LENGTH(inHigh);
  double *restrict highs = REAL(inHigh);   // pointer to high prices
  double *restrict lows = REAL(inLow);     // pointer to low prices
  double *restrict closes = REAL(inClose); // pointer to close prices
  int period = INTEGER(optTimePeriod)[0];  // lookback period

  // allocate result matrix: n rows × 3 cols
  SEXP result = PROTECT(allocMatrix(REALSXP, n, 3));
  double *upper = REAL(result);
  double *middle = upper + n;
  double *lower = upper + 2 * n;

  int outBeg, outNb;
  // clang-format off
  TA_RetCode ret = TA_ACCBANDS(
    0, 
    n - 1, 
    highs, 
    lows, 
    closes, 
    period, 
    &outBeg, 
    &outNb,
    upper + outBeg,
    middle + outBeg,
    lower + outBeg
  );
  // clang-format on

  // shift each array
  //
  // NOTE: There is most likely a better
  //       way to do this. But as it is,
  //       this move costs 3 x 5.33 ms for a
  //       normally distributed double vector of
  //       of length 1e7; the SMA costs 57ms
  //       its 10% overhead, which is alot. But
  //       if anyone is doing calculations on 1e7
  //       they probably have bigger thing to worry
  //       about.
  shift_array(upper, n, outBeg);
  shift_array(middle, n, outBeg);
  shift_array(lower, n, outBeg);

  // set column names to lowercase as requested
  SEXP dims = PROTECT(allocVector(VECSXP, 2));
  SEXP cnames = PROTECT(allocVector(STRSXP, 3));
  SET_STRING_ELT(cnames, 0, mkChar("upper"));
  SET_STRING_ELT(cnames, 1, mkChar("middle"));
  SET_STRING_ELT(cnames, 2, mkChar("lower"));
  SET_VECTOR_ELT(dims, 0, R_NilValue);
  SET_VECTOR_ELT(dims, 1, cnames);
  setAttrib(result, R_DimNamesSymbol, dims);

  UNPROTECT(3);
  return result;
}
