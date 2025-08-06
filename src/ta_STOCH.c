// Interface to ta_STOCH.c (Slow Stochastic)
//
// Parameters
//   high            – numeric vector of 'High' prices
//   low             – numeric vector of 'Low' prices
//   close           – numeric vector of 'Close' prices
//   fastk_period    – integer lookback for %K
//   slowk_period    – integer smoothing for %K
//   slowk_matype    – integer MA type for %K
//   slowd_period    – integer lookback for %D
//   slowd_matype    – integer MA type for %D
//
// Description
//   Returns an N×2 matrix with columns 'slowk' and 'slowd', NA-filled
//   for initial lookback.
#include "lib.h"
#include <R.h>
#include <Rinternals.h>
#include "ta_libc.h"

SEXP impl_ta_STOCH(SEXP high, SEXP low, SEXP close,
                   SEXP fastk_period, SEXP slowk_period, SEXP slowk_matype,
                   SEXP slowd_period, SEXP slowd_matype) {
    int pCount = 0;
    high           = PROTECT(coerceVector(high, REALSXP));       pCount++;
    low            = PROTECT(coerceVector(low, REALSXP));        pCount++;
    close          = PROTECT(coerceVector(close, REALSXP));      pCount++;
    fastk_period   = PROTECT(coerceVector(fastk_period, INTSXP));pCount++;
    slowk_period   = PROTECT(coerceVector(slowk_period, INTSXP));pCount++;
    slowk_matype   = PROTECT(coerceVector(slowk_matype, INTSXP));pCount++;
    slowd_period   = PROTECT(coerceVector(slowd_period, INTSXP));pCount++;
    slowd_matype   = PROTECT(coerceVector(slowd_matype, INTSXP));pCount++;

    int n = length(high);
    const double * __restrict__ inHigh  = REAL(high);
    const double * __restrict__ inLow   = REAL(low);
    const double * __restrict__ inClose = REAL(close);
    int kP = INTEGER(fastk_period)[0];
    int sk = INTEGER(slowk_period)[0];
    int sm = INTEGER(slowk_matype)[0];
    int dP = INTEGER(slowd_period)[0];
    int dm = INTEGER(slowd_matype)[0];

    int outBeg, outNB;
    SEXP result    = PROTECT(allocMatrix(REALSXP, n, 2));       pCount++;
    double * __restrict__ mat = REAL(result);
    double * __restrict__ outSlowK = mat;
    double * __restrict__ outSlowD = mat + n;

    TA_RetCode ret = TA_STOCH(0, n - 1,
                              inHigh, inLow, inClose,
                              kP, sk, sm, dP, dm,
                              &outBeg, &outNB,
                              outSlowK + outBeg,
                              outSlowD + outBeg);
    if (ret != TA_SUCCESS) {
        UNPROTECT(pCount);
        error("TA_STOCH failed: return code %d", ret);
    }
    for (register int i = 0; i < outBeg; ++i) {
        outSlowK[i] = NA_REAL;
        outSlowD[i] = NA_REAL;
    }
    SEXP colnames  = PROTECT(allocVector(STRSXP, 2));            pCount++;
    SET_STRING_ELT(colnames, 0, mkChar("slowk"));
    SET_STRING_ELT(colnames, 1, mkChar("slowd"));
    SEXP dimnames  = PROTECT(allocVector(VECSXP, 2));           pCount++;
    SET_VECTOR_ELT(dimnames, 0, R_NilValue);
    SET_VECTOR_ELT(dimnames, 1, colnames);
    setAttrib(result, R_DimNamesSymbol, dimnames);

    UNPROTECT(pCount);
    return result;
}