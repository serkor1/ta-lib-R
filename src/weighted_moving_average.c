#include "lib.h"

SEXP c_weighted_moving_average(const SEXP x, const SEXP lag) {
    const int timePeriod = asInteger(lag);
    const int len = length(x);
    const double * __restrict__ x_data = REAL(x);
    int outBegIdx = 0, outNBElement = 0;

    // Output buffer: at most len elements; R_alloc is fast and GC-managed
    double * __restrict__ outReal = (double*) R_alloc((size_t)len, sizeof(double));

    // Call TA-LIB WMA: startIdx=0, endIdx=len-1
    TA_RetCode ret = TA_WMA(0, len - 1, x_data, timePeriod, &outBegIdx, &outNBElement, outReal);

    // Prepare full-length vector with leading NAs (lookback)
    SEXP ans = PROTECT(allocVector(REALSXP, len));
    double *ans_d = REAL(ans);

    if (ret != TA_SUCCESS || outNBElement <= 0) {
        // Failure: fill with NA
        for (int i = 0; i < len; ++i) ans_d[i] = NA_REAL;
        UNPROTECT(1);
        return ans;
    }

    // Leading NA for lookback
    for (int i = 0; i < outBegIdx; ++i) ans_d[i] = NA_REAL;

    // Copy the computed WMA results
    memcpy(ans_d + outBegIdx, outReal, (size_t)outNBElement * sizeof(double));

    // (Trailing part should naturally be filled by outNBElement; since endIdx = len-1, no further action)

    UNPROTECT(1);
    return ans;
}