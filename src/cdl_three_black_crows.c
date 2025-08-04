#include "lib.h"

SEXP c_cdl3blackcrows(const SEXP open, const SEXP high, const SEXP low,
                      const SEXP close) {
  const int len = length(open); // assume all four are same length
  const double *__restrict__ inOpen = REAL(open);
  const double *__restrict__ inHigh = REAL(high);
  const double *__restrict__ inLow = REAL(low);
  const double *__restrict__ inClose = REAL(close);

  // Determine lookback so we know where the first output will land.
  int lookback = TA_CDL3BLACKCROWS_Lookback(); // number of bars consumed before
                                               // first output

  // Prepare result vector and initialize to NA_INTEGER for lookback/trailing.
  SEXP ans = PROTECT(allocVector(INTSXP, len));
  int *ans_i = INTEGER(ans);
  for (int i = 0; i < len; ++i)
    ans_i[i] = NA_INTEGER;

  // If there is not enough data to produce any output, just return all-NA.
  if (len <= lookback) {
    UNPROTECT(1);
    return ans;
  }

  int outBegIdx = 0, outNBElement = 0;

  // Call TA-LIB starting at the lookback index so we already know outBegIdx ==
  // lookback.
  TA_RetCode ret = TA_CDL3BLACKCROWS(
      lookback, // startIdx
      len - 1,  // endIdx
      inOpen, inHigh, inLow, inClose, &outBegIdx, &outNBElement,
      /* output buffer pointed into the R vector to avoid copy: */
      ans_i + lookback // fills ans_i[lookback .. lookback+outNBElement-1]
  );

  // Sanity: if TA-LIB failed or produced nothing, leave ans as all NAs.
  if (ret != TA_SUCCESS || outNBElement <= 0) {
    UNPROTECT(1);
    return ans;
  }

  // (Optional) Could verify outBegIdx == lookback and outNBElement == (len -
  // lookback), but we're skipping extra branching for speed per your directive.

  UNPROTECT(1);
  return ans;
}