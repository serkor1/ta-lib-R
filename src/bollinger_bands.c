/* Bollinger Bands
 *
 */
#include "lib.h"

// .Call interface: x, timePeriod (int scalar or NA), nbDevUp (double or NA),
// nbDevDn, maType (string)
SEXP c_bollinger_bands(const SEXP x, const SEXP timePeriod, const SEXP nbDevUp,
                       const SEXP nbDevDn, const SEXP maType) {

  static int ta_initialized = 0;
  if (!ta_initialized) {
    if (TA_Initialize() != TA_SUCCESS)
      error("TA_Initialize failed");
    ta_initialized = 1;
  }

  if (!isReal(x))
    error("Input vector x must be numeric (double).");

  int n = LENGTH(x);
  double *inReal = REAL(x);

  // Parameters with defaults
  int optInTimePeriod = 20;
  double optInNbDevUp = 2.0;
  double optInNbDevDn = 2.0;
  TA_MAType optInMAType = TA_MAType_SMA;

  if (timePeriod != R_NilValue && isInteger(timePeriod) &&
      LENGTH(timePeriod) >= 1) {
    int tp = INTEGER(timePeriod)[0];
    if (tp != NA_INTEGER)
      optInTimePeriod = tp;
  } else if (timePeriod != R_NilValue && isReal(timePeriod) &&
             LENGTH(timePeriod) >= 1) {
    double tp_d = REAL(timePeriod)[0];
    if (!ISNA(tp_d))
      optInTimePeriod = (int)tp_d;
  }

  if (nbDevUp != R_NilValue && isReal(nbDevUp) && LENGTH(nbDevUp) >= 1) {
    double v = REAL(nbDevUp)[0];
    if (!ISNA(v))
      optInNbDevUp = v;
  }
  if (nbDevDn != R_NilValue && isReal(nbDevDn) && LENGTH(nbDevDn) >= 1) {
    double v = REAL(nbDevDn)[0];
    if (!ISNA(v))
      optInNbDevDn = v;
  }

  optInMAType = map_moving_average(maType);

  // Compute lookback
  int lookback = TA_BBANDS_Lookback(optInTimePeriod, optInNbDevUp, optInNbDevDn,
                                    optInMAType);
  if (lookback < 0)
    error("Invalid parameters for lookback.");

  // Allocate output vectors of length n (we will pad front with NA)
  SEXP upper = PROTECT(allocVector(REALSXP, n));
  SEXP middle = PROTECT(allocVector(REALSXP, n));
  SEXP lower = PROTECT(allocVector(REALSXP, n));
  double *upper_p = REAL(upper);
  double *middle_p = REAL(middle);
  double *lower_p = REAL(lower);

  // Initialize output to NA
  for (int i = 0; i < n; ++i) {
    upper_p[i] = NA_REAL;
    middle_p[i] = NA_REAL;
    lower_p[i] = NA_REAL;
  }

  // If not enough data, return early with all NAs and outNBElement=0
  if (n == 0 || n - 1 < lookback) {
    SEXP outBegIdx = PROTECT(ScalarInteger(NA_INTEGER));
    SEXP outNBElement = PROTECT(ScalarInteger(0));
    SEXP res = PROTECT(allocVector(VECSXP, 5));
    SET_VECTOR_ELT(res, 0, upper);
    SET_VECTOR_ELT(res, 1, middle);
    SET_VECTOR_ELT(res, 2, lower);
    SET_VECTOR_ELT(res, 3, outBegIdx);
    SET_VECTOR_ELT(res, 4, outNBElement);
    SEXP names = PROTECT(allocVector(STRSXP, 5));
    SET_STRING_ELT(names, 0, mkChar("upper"));
    SET_STRING_ELT(names, 1, mkChar("middle"));
    SET_STRING_ELT(names, 2, mkChar("lower"));
    SET_STRING_ELT(names, 3, mkChar("outBegIdx"));
    SET_STRING_ELT(names, 4, mkChar("outNBElement"));
    setAttrib(res, R_NamesSymbol, names);
    UNPROTECT(6);
    return res;
  }

  // Temporary buffers of size at least n (TA will only fill outNBElement
  // entries)
  int outBegIdx = 0;
  int outNBElement = 0;

  TA_RetCode ret = TA_BBANDS(
      0,     // startIdx
      n - 1, // endIdx
      inReal, optInTimePeriod, optInNbDevUp, optInNbDevDn, optInMAType,
      &outBegIdx, &outNBElement,
      upper_p + outBegIdx, // trick: TA writes starting at 0, so we copy later.
                           // Simpler to use temporary arrays.
      middle_p + outBegIdx, lower_p + outBegIdx);

  if (ret != TA_SUCCESS) {
    error("TA_BBANDS failed with code %d", ret);
  }

  // Note: TA_BBANDS writes output starting from index 0 in its provided output
  // arrays. We passed pointers offset by outBegIdx so valid data is already
  // in-place. However TA_BBANDS expects output arrays big enough; we gave
  // full-length with shift.

  // Prepare return list
  SEXP outBegIdx_SEXP = PROTECT(ScalarInteger(outBegIdx));
  SEXP outNBElement_SEXP = PROTECT(ScalarInteger(outNBElement));
  SEXP res = PROTECT(allocVector(VECSXP, 5));
  SET_VECTOR_ELT(res, 0, upper);
  SET_VECTOR_ELT(res, 1, middle);
  SET_VECTOR_ELT(res, 2, lower);
  SET_VECTOR_ELT(res, 3, outBegIdx_SEXP);
  SET_VECTOR_ELT(res, 4, outNBElement_SEXP);
  SEXP names = PROTECT(allocVector(STRSXP, 5));
  SET_STRING_ELT(names, 0, mkChar("upper"));
  SET_STRING_ELT(names, 1, mkChar("middle"));
  SET_STRING_ELT(names, 2, mkChar("lower"));
  SET_STRING_ELT(names, 3, mkChar("outBegIdx"));
  SET_STRING_ELT(names, 4, mkChar("outNBElement"));
  setAttrib(res, R_NamesSymbol, names);

  UNPROTECT(6);
  return res;
}