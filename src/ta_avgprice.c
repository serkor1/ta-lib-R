/* Average Price
 *
 * Function Description
 *
 * x: An object coercible to double matrix on the form Open, High, Low, Close
 * and Volume
 *
 *
 *
 *
 */
#include "lib.h"

SEXP c_average_price(SEXP const x) {
  if (TYPEOF(x) != REALSXP)
    Rf_error("Input must be a numeric (double) matrix.");
  SEXP dim = GET_DIM(x);
  if (dim == R_NilValue || LENGTH(dim) < 2)
    Rf_error("Input must have a dim attribute.");
  int nrow = INTEGER(dim)[0];
  int ncol = INTEGER(dim)[1];
  if (ncol != 4)
    Rf_error("Input matrix must have 4 columns: Open, High, Low, Close.");

  double *mat = REAL(x);
  const double *inOpen = mat + 0 * nrow;
  const double *inHigh = mat + 1 * nrow;
  const double *inLow = mat + 2 * nrow;
  const double *inClose = mat + 3 * nrow;

  ensure_ta_initialized();

  int startIdx = 0;
  int endIdx = nrow - 1;
  int outBegIdx = 0, outNBElement = 0;
  int maxSize = endIdx - startIdx + 1;
  double *outReal = (double *)R_alloc((size_t)maxSize, sizeof(double));

  TA_RetCode ret = TA_AVGPRICE(startIdx, endIdx, inOpen, inHigh, inLow, inClose,
                               &outBegIdx, &outNBElement, outReal);
  if (ret != TA_SUCCESS) {
    Rf_error("TA_AVGPRICE failed with code %d.", ret);
  }

  SEXP result = PROTECT(allocVector(REALSXP, (R_xlen_t)nrow));
  double *res = REAL(result);

  /* initialize to NA */
  for (int i = 0; i < nrow; ++i)
    res[i] = NA_REAL;

  /* sanity-check the returned window before copying */
  if (outNBElement > 0) {
    if (outBegIdx < 0 || outBegIdx + outNBElement > nrow) {
      UNPROTECT(1);
      Rf_error("TA_AVGPRICE returned invalid outBegIdx/outNBElement: "
               "outBegIdx=%d outNBElement=%d",
               outBegIdx, outNBElement);
    }
    for (int i = 0; i < outNBElement; ++i) {
      res[outBegIdx + i] = outReal[i];
    }
  }

  UNPROTECT(1);
  return result;
}
