// Interface to TA_AVGPRICE
//
// Parameters
// x: A OHLCV-matrix
//
// Description
// `x` needs to have at least OHLC.
#include "R_ext/Arith.h"
#include "R_ext/Memory.h"
#include "Rdefines.h"
#include "Rinternals.h"
#include "ta_defs.h"
#include "ta_func.h"

SEXP impl_TA_AVGPRICE(const SEXP x) {

  // 1) extract dimensions
  //    form `x`
  SEXP x_dimension = GET_DIM(x);

  // 1.1) assert dimension
  //      availability
  if (x_dimension == R_NilValue || LENGTH(x_dimension) < 2) {
    Rf_error("`x` must have dim attribute");
  }

  const int nrow = INTEGER(x_dimension)[0];
  const int ncol = INTEGER(x_dimension)[1];

  // 2) construct OHLC
  //    matrix and extract
  //    values
  double *OHLC = REAL(x);
  const double *inOpen = OHLC + 0 * nrow;
  const double *inHigh = OHLC + 1 * nrow;
  const double *inLow = OHLC + 2 * nrow;
  const double *inClose = OHLC + 3 * nrow;

  const int startIdx = 0;
  const int endIdx = nrow - 1;
  int outBegIdx = 0, outNBElement = 0;
  const int maxSize = endIdx - startIdx + 1;
  double *outReal = (double *)R_alloc((size_t)maxSize, sizeof(double));

  // clang-format off
  // 3) call TA_AVGPRICE
  //    which returns a code
  TA_RetCode ret = TA_AVGPRICE(
    startIdx, 
    endIdx, 
    inOpen, 
    inHigh, 
    inLow, 
    inClose,
    &outBegIdx, 
    &outNBElement, 
    outReal);
  // clang-format on

  // 3.1) assert success
  //      of function. If it
  //      fails here its a bug
  if (ret != TA_SUCCESS) {
    Rf_error("`TA_AVGPRICE()` failed with code %d.", ret);
  }

  // 4) prepare output
  //    for R
  SEXP output = PROTECT(allocVector(REALSXP, (R_xlen_t)nrow));
  double *output_ptr = REAL(output);

  // 4.1) initialize to NA
  //      to ensure size(input) == size(output)
  for (int i = 0; i < nrow; ++i) {
    output_ptr[i] = NA_REAL;
  }

  // 4.2) populate output
  //      vector
  for (int i = 0; i < outNBElement; ++i) {
    output_ptr[outBegIdx + i] = outReal[i];
  }

  UNPROTECT(1);
  return output;
}
