// Interface to ta_MIDPRICE.c
//
// Parameters
// x: A OHLC matrix
//
#include "R_ext/Error.h"
#include "Rdefines.h"
#include "Rinternals.h"
#include "ta_func.h"

SEXP impl_MIDPRICE(const SEXP x, const SEXP n) {

  // 1) extract dimensions
  //    from `x`
  SEXP x_dimension = GET_DIM(x);

  // 1.1) assert dimensiona availability
  if (x_dimension == R_NilValue || LENGTH(x_dimension) < 2) {
    Rf_error("`x` must have dim attribute");
  }
  const int nrow = INTEGER(x_dimension)[0];
  const int ncol = INTEGER(x_dimension)[1];

  // 2) extract High and Low
  double *HL = REAL(x);
  const double *inHigh = HL + 1 * nrow;
  const double *inLow = HL + 2 * nrow;

  // 2.1) extract time period
  const int *optInTimePeriod = INTEGER(n);

  const int startIdx = 0;
  const int endIdx = nrow - 1;
  int outBegIdx = 0, outNBElement = 0;
  const int maxSize = endIdx - startIdx + 1;
  double *outReal = (double *)R_alloc((size_t)maxSize, sizeof(double));

  // clang-format off
  // 3) call TA_MEDPRICE
  TA_RetCode ret = TA_MIDPRICE(
    startIdx,
    endIdx,
    inHigh,
    inLow,
    optInTimePeriod[0],
    &outBegIdx,
    &outNBElement,
    outReal);
  // clang-format on

  // 3.1) assert success
  if (ret != TA_SUCCESS) {
    Rf_error("`TA_MEDPRICE()` failed with code %d.", ret);
  }

  // 4) prepare output for R
  SEXP output = PROTECT(allocVector(REALSXP, (R_xlen_t)nrow));
  double *output_ptr = REAL(output);

  // 4.1) initialize to NA
  for (int i = 0; i < nrow; ++i) {
    output_ptr[i] = NA_REAL;
  }

  // 4.2) populate output vector
  for (int i = 0; i < outNBElement; ++i) {
    output_ptr[outBegIdx + i] = outReal[i];
  }

  UNPROTECT(1);
  return output;
}