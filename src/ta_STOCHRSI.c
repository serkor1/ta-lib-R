// Interface to ta_STOCHRSI.c (Stochastic RSI)
//
// Parameters
//   real            – numeric vector of RSI values
//   timeperiod      – integer lookback for RSI calculation
//   fastk_period    – integer period for %K of StochRSI
//   fastd_period    – integer period for %D smoothing
//   fastd_matype    – integer MA type for %D smoothing
//
// Description
//   Returns an N×2 matrix with columns 'fastk' and 'fastd', both
//   of the same length as input, with NA for initial lookback.
#include "lib.h"
#include <R.h>
#include <Rinternals.h>
#include "ta_libc.h"

SEXP impl_ta_STOCHRSI(SEXP real, SEXP timeperiod,
                      SEXP fastk_period, SEXP fastd_period, SEXP fastd_matype) {
    int pCount = 0;
    real           = PROTECT(coerceVector(real, REALSXP));      pCount++;
    timeperiod     = PROTECT(coerceVector(timeperiod, INTSXP)); pCount++;
    fastk_period   = PROTECT(coerceVector(fastk_period, INTSXP)); pCount++;
    fastd_period   = PROTECT(coerceVector(fastd_period, INTSXP)); pCount++;
    fastd_matype   = PROTECT(coerceVector(fastd_matype, INTSXP)); pCount++;

    int n = length(real);
    const double * __restrict__ inReal = REAL(real);
    int tp = INTEGER(timeperiod)[0];
    int kP = INTEGER(fastk_period)[0];
    int dP = INTEGER(fastd_period)[0];
    int dM = INTEGER(fastd_matype)[0];

    int outBeg, outNB;
    // Allocate matrix N×2
    SEXP result    = PROTECT(allocMatrix(REALSXP, n, 2));      pCount++;
    double * __restrict__ mat = REAL(result);
    // Column pointers
    double * __restrict__ outFastK = mat;
    double * __restrict__ outFastD = mat + n;

    TA_RetCode ret = TA_STOCHRSI(0, n - 1,
                                 inReal, tp,
                                 kP, dP, dM,
                                 &outBeg, &outNB,
                                 outFastK + outBeg,
                                 outFastD + outBeg);
    if (ret != TA_SUCCESS) {
        UNPROTECT(pCount);
        error("TA_STOCHRSI failed: return code %d", ret);
    }
    // Fill initial lookback rows with NA
    for (register int i = 0; i < outBeg; ++i) {
        outFastK[i] = NA_REAL;
        outFastD[i] = NA_REAL;
    }
    // Set column names
    SEXP colnames  = PROTECT(allocVector(STRSXP, 2));           pCount++;
    SET_STRING_ELT(colnames, 0, mkChar("fastk"));
    SET_STRING_ELT(colnames, 1, mkChar("fastd"));
    SEXP dimnames  = PROTECT(allocVector(VECSXP, 2));          pCount++;
    SET_VECTOR_ELT(dimnames, 0, R_NilValue);
    SET_VECTOR_ELT(dimnames, 1, colnames);
    setAttrib(result, R_DimNamesSymbol, dimnames);

    UNPROTECT(pCount);
    return result;
}