#include "lib.h"

SEXP c_kaufman_adaptive_moving_average(const SEXP x, const SEXP period) {
    const int timePeriod = asInteger(period);
    const int len = length(x);
    const double * __restrict__ inReal = REAL(x);
    int outBegIdx = 0, outNBElement = 0;

    // TA-LIB output buffer (max size = len)
    double * __restrict__ outReal = (double *) R_alloc((size_t)len, sizeof(double));

    // Direct call to KAMA: startIdx=0, endIdx=len-1
    TA_RetCode ret = TA_KAMA(0, len - 1, inReal, timePeriod, &outBegIdx, &outNBElement, outReal);

    // Prepare result vector with NAs
    SEXP ans = PROTECT(allocVector(REALSXP, len));
    double *ans_d = REAL(ans);
    for (int i = 0; i < len; ++i)  // fill with NA (covers lookback and failure)
        ans_d[i] = NA_REAL;

    if (ret == TA_SUCCESS && outNBElement > 0) {
        // copy computed KAMA values at their proper offset
        memcpy(ans_d + outBegIdx, outReal, (size_t)outNBElement * sizeof(double));
    }

    UNPROTECT(1);
    return ans;
}