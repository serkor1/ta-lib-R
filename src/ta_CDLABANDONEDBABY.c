// Interface to TA_CDLABANDONEDBABY (Abandoned Baby)
//
// Parameters
//   open, high, low, close : numeric vectors (same length)
//   penetration            : numeric scalar (double) – gap penetration (default
//   0) normalize_flag         : logical scalar; when TRUE divide outputs by 100
//
// Description
//   Identifies Abandoned Baby patterns. Returns an integer vector of length n,
//   padded with NA_INTEGER for the initial lookback. Values are (-100, 0, +100)
//   or (-1, 0, +1) if normalized.

#include "R_ext/Arith.h"
#include "Rdefines.h"
#include "Rinternals.h"
#include "lib.h"
#include "normalize.h"
#include "shift.h"
#include <stdbool.h>
#include <ta_libc.h>

// clang-format off
SEXP impl_ta_CDLABANDONEDBABY(
  SEXP open,
  SEXP high,
  SEXP low,
  SEXP close,
  SEXP penetration,
  SEXP normalize_flag) {
  // clang-format on

  int protect_count = 0;

  const double *restrict open_ptr = REAL(open);
  const double *restrict high_ptr = REAL(high);
  const double *restrict low_ptr = REAL(low);
  const double *restrict close_ptr = REAL(close);
  const double pen = REAL(penetration)[0];
  int n = LENGTH(open);

  SEXP result = PROTECT(allocVector(INTSXP, n));
  protect_count++;
  int *restrict out_ptr = INTEGER(result);

  const int minimum_lookback = TA_CDLABANDONEDBABY_Lookback(pen);

  if (n < minimum_lookback) {
    Rf_warning(
      "Input length (%d) is smaller than required lookback (%d).",
      n,
      minimum_lookback);
    for (int i = 0; i < n; ++i)
      out_ptr[i] = NA_INTEGER;

  } else {
    int outBeg = 0, outNb = 0;

    TA_RetCode rc = TA_CDLABANDONEDBABY(
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

    if (rc != TA_SUCCESS) {
      UNPROTECT(protect_count);
      Rf_error("TA_CDLABANDONEDBABY failed: return code %d", rc);
    }

    shift_array(out_ptr, n, outBeg);

    if (LOGICAL_VALUE(normalize_flag)) {
      normalize(out_ptr, n, 100, outBeg);
    }
  }

  UNPROTECT(protect_count);
  return result;
}
