// Interface to ta_AROON.c
//
// Parameters
//   inHigh     : Numeric vector of high prices.
//   inLow      : Numeric vector of low prices.
//   timePeriod : Integer, look-back period for Aroon.
//
// Description
//   Computes the Aroon indicator, which returns two series:
//   AroonDown and AroonUp. Returns an n×2 matrix (columns in order:
//   "aroondown", "aroonup"), with positions before lookback set to NA.
#include "lib.h"
#include <R.h>
#include <Rinternals.h>
#include <ta_libc.h>

SEXP impl_ta_AROON(SEXP inHighSEXP, SEXP inLowSEXP, SEXP timePeriodSEXP) {
    R_xlen_t n = xlength(inHighSEXP);
    if (xlength(inLowSEXP) != n)
        error("inHigh and inLow must have the same length");

    int timePeriod = asInteger(timePeriodSEXP);
    const double *restrict inHigh = REAL(inHighSEXP);
    const double *restrict inLow  = REAL(inLowSEXP);

    // Allocate an n×2 matrix
    SEXP outMat  = PROTECT(allocMatrix(REALSXP, n, 2));
    double *restrict outDown = REAL(outMat);         // column 0
    double *restrict outUp   = REAL(outMat) + n;     // column 1

    // Set up dimnames for columns: lowercase names
    SEXP dimnames = PROTECT(allocVector(VECSXP, 2));
    SET_VECTOR_ELT(dimnames, 0, R_NilValue);  // no row names
    SEXP colNames = PROTECT(allocVector(STRSXP, 2));
    SET_STRING_ELT(colNames, 0, mkChar("aroondown"));
    SET_STRING_ELT(colNames, 1, mkChar("aroonup"));
    SET_VECTOR_ELT(dimnames, 1, colNames);
    setAttrib(outMat, R_DimNamesSymbol, dimnames);

    // Call TA-Lib
    int outBegIdx = 0, outNBElement = 0;
    TA_RetCode ret = TA_AROON(
        0, (int)n - 1,
        inHigh, inLow,
        timePeriod,
        &outBegIdx, &outNBElement,
        outDown, outUp
    );
    if (ret != TA_SUCCESS) {
        UNPROTECT(3);
        error("TA_AROON failed with error code %d", ret);
    }

    // Fill invalid leading positions with NA
    for (int i = 0; i < outBegIdx; ++i) {
        outDown[i] = NA_REAL;
        outUp[i]   = NA_REAL;
    }

    // Shift valid values into place
    memmove(outDown + outBegIdx, outDown, (size_t)outNBElement * sizeof(double));
    memmove(outUp   + outBegIdx, outUp,   (size_t)outNBElement * sizeof(double));

    // Fill trailing positions with NA
    for (int i = outBegIdx + outNBElement; i < n; ++i) {
        outDown[i] = NA_REAL;
        outUp[i]   = NA_REAL;
    }

    UNPROTECT(3);
    return outMat;
}
