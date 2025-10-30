// Interface to TA_CDLDARKCLOUDCOVER
//
// Parameters
//   open, high, low, close : numeric vectors (same length)
//   penetration            : numeric scalar (double), typically in [0,100]
//   normalize_flag         : logical; if TRUE divide outputs by 100 starting at
//   outBeg
//
// Returns: integer vector (length n)

#include "R_ext/Arith.h"
#include "Rdefines.h"
#include "Rinternals.h"
#include "lib.h"
#include "normalize.h"
#include "shift.h"
#include <ta_libc.h>

SEXP impl_ta_CDLDARKCLOUDCOVER(
  SEXP open,
  SEXP high,
  SEXP low,
  SEXP close,
  SEXP penetration,
  SEXP normalize_flag) {
  int protect_count = 0;

  const double *restrict open_ptr = REAL(open);
  const double *restrict high_ptr = REAL(high);
  const double *restrict low_ptr = REAL(low);
  const double *restrict close_ptr = REAL(close);
  const double pen = REAL(penetration)[0];
  const int n = LENGTH(open);

  SEXP result = PROTECT(allocVector(INTSXP, n));
  protect_count++;
  int *restrict out_ptr = INTEGER(result);

  // Lookback may depend on penetration in TA-Lib
  const int minimum_lookback = TA_CDLDARKCLOUDCOVER_Lookback(pen);

  if (n < minimum_lookback) {
    Rf_warning(
      "Input length (%d) is smaller than required lookback (%d).",
      n,
      minimum_lookback);
    for (size_t i = 0; i < (size_t)n; ++i)
      out_ptr[i] = NA_INTEGER;

  } else {
    int outBeg = 0, outNb = 0;
    TA_RetCode return_code = TA_CDLDARKCLOUDCOVER(
      0,
      n - 1,
      open_ptr,
      high_ptr,
      low_ptr,
      close_ptr,
      pen,
      &outBeg,
      &outNb,
      out_ptr);

    if (return_code != TA_SUCCESS) {
      UNPROTECT(protect_count);
      Rf_error("TA_CDLDARKCLOUDCOVER failed: return code %d", return_code);
    }

    shift_array(out_ptr, n, outBeg);
    if (LOGICAL_VALUE(normalize_flag)) {
      normalize(out_ptr, n, 100, outBeg);
    }
  }

  UNPROTECT(protect_count);
  return result;
}
