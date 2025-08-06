// Interface to ta_ULTOSC.c (Ultimate Oscillator)
//
// Parameters
//   high            – numeric vector of 'High' prices
//   low             – numeric vector of 'Low' prices
//   close           – numeric vector of 'Close' prices
//   timeperiod1     – integer SEXP for first lookback (e.g. 7)
//   timeperiod2     – integer SEXP for second lookback (e.g. 14)
//   timeperiod3     – integer SEXP for third lookback (e.g. 28)
//
// Description
//   Returns a numeric vector of the same length as inputs containing
//   the Ultimate Oscillator, with NA for indices before the lookback.
#include "lib.h"
#include <R.h>
#include <Rinternals.h>
#include "ta_libc.h"

SEXP impl_ta_ULTOSC(SEXP high, SEXP low, SEXP close,
                    SEXP timeperiod1, SEXP timeperiod2, SEXP timeperiod3) {
    int pCount = 0;
    // Coerce inputs to REALSXP/INTSXP and protect
    high           = PROTECT(coerceVector(high, REALSXP));   pCount++;
    low            = PROTECT(coerceVector(low, REALSXP));    pCount++;
    close          = PROTECT(coerceVector(close, REALSXP));  pCount++;
    timeperiod1    = PROTECT(coerceVector(timeperiod1, INTSXP)); pCount++;
    timeperiod2    = PROTECT(coerceVector(timeperiod2, INTSXP)); pCount++;
    timeperiod3    = PROTECT(coerceVector(timeperiod3, INTSXP)); pCount++;

    int n = length(high);
    // Extract C pointers with restrict qualifier for speed
    const double * __restrict__ inHigh  = REAL(high);
    const double * __restrict__ inLow   = REAL(low);
    const double * __restrict__ inClose = REAL(close);
    int p1 = INTEGER(timeperiod1)[0];
    int p2 = INTEGER(timeperiod2)[0];
    int p3 = INTEGER(timeperiod3)[0];

    int outBeg, outNB;
    // Allocate output vector of full length
    SEXP result    = PROTECT(allocVector(REALSXP, n)); pCount++;
    double * __restrict__ out = REAL(result);

    // Call TA-Lib function
    TA_RetCode ret = TA_ULTOSC(0, n - 1,
                               inHigh, inLow, inClose,
                               p1, p2, p3,
                               &outBeg, &outNB,
                               out + outBeg);
    if (ret != TA_SUCCESS) {
        UNPROTECT(pCount);
        error("TA_ULTOSC failed: return code %d", ret);
    }
    // Fill initial lookback positions with NA
    for (register int i = 0; i < outBeg; ++i)
        out[i] = NA_REAL;

    UNPROTECT(pCount);
    return result;
}



