#include "lib.h"

SEXP c_commodity_channel_index(const SEXP high, const SEXP low,
                               const SEXP close, const SEXP period) {
  const int timePeriod = asInteger(period);
  const int len = length(high); // assume low and close are same length
  const double *__restrict__ h = REAL(high);
  const double *__restrict__ l = REAL(low);
  const double *__restrict__ c = REAL(close);
  int outBegIdx = 0, outNBElement = 0;

  // TA-LIB output buffer (max size = len)
  double *__restrict__ outReal = (double *)R_alloc((size_t)len, sizeof(double));

  // Call TA-LIB CCI: startIdx=0, endIdx=len-1
  TA_RetCode ret = TA_CCI(0, len - 1, h, l, c, timePeriod, &outBegIdx,
                          &outNBElement, outReal);

  // Prepare full-length output with leading/trailing NA
  SEXP ans = PROTECT(allocVector(REALSXP, len));
  double *ans_d = REAL(ans);

  // Default everything to NA first (covers error case and trailing)
  for (int i = 0; i < len; ++i)
    ans_d[i] = NA_REAL;

  if (ret == TA_SUCCESS && outNBElement > 0) {
    // Leading NAs are already in place up to outBegIdx-1
    // Copy computed CCI values
    memcpy(ans_d + outBegIdx, outReal, (size_t)outNBElement * sizeof(double));
  }
  // else: leave as NA (failure or no output)

  UNPROTECT(1);
  return ans;
}