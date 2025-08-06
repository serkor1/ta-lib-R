// Interface to ta_STOCHF.c (Fast Stochastic)
//
// Parameters
//   high            – numeric vector of 'High' prices
//   low             – numeric vector of 'Low' prices
//   close           – numeric vector of 'Close' prices
//   fastk_period    – integer lookback for %K
//   fastd_period    – integer lookback for %D
//   fastd_matype    – integer MA type for %D
//
// Description
//   Returns an N×2 matrix with columns 'fastk' and 'fastd', NA-filled
//   for initial lookback.
#include "lib.h"
#include <R.h>
#include <Rinternals.h>
#include "ta_libc.h"

SEXP impl_ta_STOCHF(SEXP high, SEXP low, SEXP close,
                    SEXP fastk_period, SEXP fastd_period, SEXP fastd_matype) {
    int pCount = 0;
    high           = PROTECT(coerceVector(high, REALSXP));       pCount++;
    low            = PROTECT(coerceVector(low, REALSXP));        pCount++;
    close          = PROTECT(coerceVector(close, REALSXP));      pCount++;
    fastk_period   = PROTECT(coerceVector(fastk_period, INTSXP));pCount++;
    fastd_period   = PROTECT(coerceVector(fastd_period, INTSXP));pCount++;
    fastd_matype   = PROTECT(coerceVector(fastd_matype, INTSXP));pCount++;

    int n = length(high);
    const double * __restrict__ inHigh  = REAL(high);
    const double * __restrict__ inLow   = REAL(low);
    const double * __restrict__ inClose = REAL(close);
    int kP = INTEGER(fastk_period)[0];
    int dP = INTEGER(fastd_period)[0];
    int dm = INTEGER(fastd_matype)[0];

    int outBeg, outNB;
    SEXP result    = PROTECT(allocMatrix(REALSXP, n, 2));       pCount++;
    double * __restrict__ mat = REAL(result);
    double * __restrict__ outFastK = mat;
    double * __restrict__ outFastD = mat + n;

    TA_RetCode ret = TA_STOCHF(0, n - 1,
                               inHigh, inLow, inClose,
                               kP, dP, dm,
                               &outBeg, &outNB,
                               outFastK + outBeg,
                               outFastD + outBeg);
    if (ret != TA_SUCCESS) {
        UNPROTECT(pCount);
        error("TA_STOCHF failed: return code %d", ret);
    }
    for (register int i = 0; i < outBeg; ++i) {
        outFastK[i] = NA_REAL;
        outFastD[i] = NA_REAL;
    }
    SEXP colnames  = PROTECT(allocVector(STRSXP, 2));            pCount++;
    SET_STRING_ELT(colnames, 0, mkChar("fastk"));
    SET_STRING_ELT(colnames, 1, mkChar("fastd"));
    SEXP dimnames  = PROTECT(allocVector(VECSXP, 2));           pCount++;
    SET_VECTOR_ELT(dimnames, 0, R_NilValue);
    SET_VECTOR_ELT(dimnames, 1, colnames);
    setAttrib(result, R_DimNamesSymbol, dimnames);

    UNPROTECT(pCount);
    return result;
}
