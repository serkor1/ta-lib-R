// interface to ta_CDLHARAMICROSS.c
//
// Description
//   R wrapper for TA-Lib's CDL Harami Cross pattern detector.
//   Produces an integer series with TA-Lib sign semantics.
//
// Parameters
//   open, high, low, close : numeric vectors, equal length
//   normalize_flag         : logical scalar; if TRUE divide outputs by 100
//
// Returns
//   Integer vector length n with pattern codes shifted to align with inputs.
//   +100 bullish Harami Cross, -100 bearish Harami Cross, 0 otherwise.
//   If normalize_flag is TRUE, returns +1, -1, or 0.

#include "R_ext/Arith.h"
#include "Rinternals.h"
#include "lib.h"
#include "normalize.h"
#include "shift.h"
#include <stdbool.h>
#include <ta_libc.h>

// clang-format off
SEXP impl_ta_CDLHARAMICROSS(
  SEXP open,
  SEXP high,
  SEXP low,
  SEXP close,
  SEXP normalize_flag
) {
  // clang-format on
  int protect_count = 0;

  const int n = LENGTH(open);
  const double *restrict open_ptr = REAL(open);
  const double *restrict high_ptr = REAL(high);
  const double *restrict low_ptr = REAL(low);
  const double *restrict close_ptr = REAL(close);

  SEXP result = PROTECT(allocVector(INTSXP, n));
  protect_count++;
  int *restrict out_ptr = INTEGER(result);

  const int minimum_lookback = TA_CDLHARAMICROSS_Lookback();

  if (n < minimum_lookback) {
    Rf_warning(
      "Input length (%d) is smaller than required lookback (%d).",
      n,
      minimum_lookback);
    for (int i = 0; i < n; ++i)
      out_ptr[i] = NA_INTEGER;
  } else {
    int out_begin = 0, out_number = 0;

    // clang-format off
    TA_RetCode return_code = TA_CDLHARAMICROSS(
       0,
       n - 1,
       open_ptr,
       high_ptr,
       low_ptr,
       close_ptr,
       &out_begin,
       &out_number,
       out_ptr
    );
    // clang-format on

    if (return_code != TA_SUCCESS) {
      UNPROTECT(protect_count);
      Rf_error("TA_CDLHARAMICROSS failed: return code %d", return_code);
    }

    shift_array(out_ptr, n, out_begin);

    const bool do_normalize = LOGICAL_VALUE(normalize_flag);
    if (do_normalize)
      normalize(out_ptr, n, 100, out_begin);
  }

  UNPROTECT(protect_count);
  return result;
}
