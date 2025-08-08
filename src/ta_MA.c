// Interface to TA_MA (moving average)
//
// Parameters
//   real            – numeric vector of inputs
//   lag      – integer SEXP for MA period (1 to 100000)
//   matype          – integer SEXP for MAType (0=SMA … 8=T3)
//
// Description
//   Returns a numeric vector of the same length as `real`,
//   with NA_REAL for the first lookback samples, then the
//   moving‐average values thereafter.
#include "MAType.h"
#include "lib.h"
#include "shift.h"
#include "ta-lib/include/ta_defs.h"
#include "ta_libc.h"
#include <Rinternals.h>

SEXP impl_ta_MA(SEXP x, SEXP lag, SEXP matype) {
  // TODO: A robust input validation
  //       of maType enums, and time periods

  // protection counter
  int protection_count = 0;

  // values
  int n = length(x);
  const double *__restrict__ x_ptr = REAL(x);

  int timeperiod = INTEGER(lag)[0];
  TA_MAType MA = as_MAType(matype);

  SEXP result = PROTECT(allocVector(REALSXP, n));
  protection_count++;
  double *result_ptr = REAL(result);

  // clang-format off
    int outBeg, outNb;
    TA_RetCode output = TA_MA(
    0, 
    n - 1, 
    x_ptr, 
    timeperiod, 
    MA, 
    &outBeg, 
    &outNb, 
    result_ptr
  );
  // clang-format on

  if (output != TA_SUCCESS) {
    UNPROTECT(protection_count);
    error("TA_MA failed: return code %d", output);
  }

  shift_array(result_ptr, n, outBeg);

  UNPROTECT(protection_count);
  return result;
}