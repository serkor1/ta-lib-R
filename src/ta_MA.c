// Interface to TA_MA (moving average)
//
// Parameters
//   real            – numeric vector of inputs
//   timeperiod      – integer SEXP for MA period (1 to 100000)
//   matype          – integer SEXP for MAType (0=SMA … 8=T3)
//
// Description
//   Returns a numeric vector of the same length as `real`,
//   with NA_REAL for the first lookback samples, then the
//   moving‐average values thereafter.
#include "lib.h"
#include "ta_libc.h"
#include <R.h>
#include <Rinternals.h>

SEXP impl_ta_MA(SEXP real, SEXP timeperiod, SEXP matype) {
  int pc = 0;
  real = PROTECT(coerceVector(real, REALSXP));
  pc++;
  timeperiod = PROTECT(coerceVector(timeperiod, INTSXP));
  pc++;
  matype = PROTECT(coerceVector(matype, INTSXP));
  pc++;

  int n = length(real);
  const double *__restrict__ in = REAL(real);
  int tp = INTEGER(timeperiod)[0];
  int mt_int = INTEGER(matype)[0];

  // Validate inputs
  if (tp < 1 || tp > 100000)
    error("Invalid timeperiod %d; must be 1 to 100000", tp);
  if (mt_int < TA_MAType_SMA || mt_int > TA_MAType_T3)
    error("Invalid MAType %d; must be between %d (SMA) and %d (T3)", mt_int,
          TA_MAType_SMA, TA_MAType_T3);
  TA_MAType mt = (TA_MAType)mt_int;

  // Prepare R output vector, NA-fill
  SEXP result = PROTECT(allocVector(REALSXP, n));
  pc++;
  double *__restrict__ out = REAL(result);
  for (int i = 0; i < n; i++)
    out[i] = NA_REAL;

  // Temporary buffer for TA_MA output
  double *temp = (double *)R_alloc(n, sizeof(double));

  int outBeg, outNb;
  TA_RetCode ret = TA_MA(0, n - 1, in, tp, mt, &outBeg, &outNb, temp);
  if (ret != TA_SUCCESS) {
    UNPROTECT(pc);
    error("TA_MA failed: return code %d", ret);
  }

  // Copy the valid outputs into aligned positions
  for (int i = 0; i < outNb; i++) {
    out[outBeg + i] = temp[i];
  }

  UNPROTECT(pc);
  return result;
}
