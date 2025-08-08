// Interface to ta_BBANDS (Bollinger Bands)
//
// Parameters
//   inReal         : numeric vector of source prices.
//   optTimePeriod  : integer, lookback period (e.g. 20).
//   optNbDevUp     : double, number of standard deviations for upper band.
//   optNbDevDn     : double, number of standard deviations for lower band.
//   optMAType      : integer code of TA_MAType (e.g. TA_MAType_SMA).
//
// Description
//   Computes the upper, middle, and lower Bollinger Bands over the input
//   series. Returns an n × 3 matrix (columns "upper","middle","lower")
//   padded with NA_REAL for values where the bands are undefined.

#include "lib.h"
#include "ta-lib/include/ta_defs.h"
#include <R.h>
#include <Rinternals.h>
#include <ta_libc.h>

SEXP impl_ta_BBANDS(SEXP inReal, SEXP optTimePeriod, SEXP optNbDevUp,
                    SEXP optNbDevDn, SEXP optMAType) {
  int n = LENGTH(inReal);                 // input length
  double *restrict src = REAL(inReal);    // pointer to input data
  int period = INTEGER(optTimePeriod)[0]; // lookback
  double nbUp = REAL(optNbDevUp)[0];      // std dev up
  double nbDn = REAL(optNbDevDn)[0];      // std dev down
  int maType = INTEGER(optMAType)[0];     // MA type enum
  TA_MAType to_ma = (TA_MAType)maType;

  // allocate result matrix n rows × 3 cols
  SEXP result = PROTECT(allocMatrix(REALSXP, n, 3));
  double *upper = REAL(result);  // column 1
  double *middle = upper + n;    // column 2
  double *lower = upper + 2 * n; // column 3

  // call TA-Lib function
  int outBeg, outNb;
  // clang-format off
  TA_RetCode ret = TA_BBANDS(
    0, 
    n - 1, 
    src, 
    period, 
    nbUp, 
    nbDn, 
    to_ma, 
    &outBeg, 
    &outNb,
    upper + outBeg, 
    middle + outBeg, 
    lower + outBeg
  );
  // clang-format on

  // shift arrays
  shift_array(upper, n, outBeg);
  shift_array(middle, n, outBeg);
  shift_array(lower, n, outBeg);

  // set column names: c("upper","middle","lower")
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
