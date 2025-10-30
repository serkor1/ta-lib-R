// interface to ta_CDLLADDERBOTTOM.c
//
// Description
//   Ladder Bottom bullish reversal detector using TA-Lib's CDLLADDERBOTTOM.
//
// Parameters
//   open, high, low, close : numeric vectors (same length)
//   normalize_flag         : logical scalar; TRUE scales {-100,0,100} to
//   {-1,0,1}
//
// Returns
//   Integer vector length n with {-100, 0, 100}. Bullish pattern.
//   Leading elements prior to first computable index are NA_INTEGER.

#include "R_ext/Arith.h"
#include "Rdefines.h"
#include "Rinternals.h"
#include "lib.h"
#include "normalize.h"
#include "shift.h"
#include <stdbool.h>
#include <ta_libc.h>

// clang-format off
SEXP impl_ta_CDLLADDERBOTTOM(
  SEXP open,
  SEXP high,
  SEXP low,
  SEXP close,
  SEXP normalize_flag) {
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

  const int minimum_lookback = TA_CDLLADDERBOTTOM_Lookback();

  if (n < minimum_lookback) {
    Rf_warning(
      "Input length (%d) is smaller than required lookback (%d).",
      n,
      minimum_lookback);
    for (int i = 0; i < n; ++i)
      out_ptr[i] = NA_INTEGER;

  } else {
    int output_begin = 0;
    int output_count = 0;

    // clang-format off
    TA_RetCode return_code = TA_CDLLADDERBOTTOM(
       0,
       n - 1,
       open_ptr,
       high_ptr,
       low_ptr,
       close_ptr,
       &output_begin,
       &output_count,
       out_ptr
    );
    // clang-format on

    if (return_code != TA_SUCCESS) {
      UNPROTECT(protect_count);
      Rf_error("TA_CDLLADDERBOTTOM failed: return code %d", return_code);
    }

    // Align to full length
    shift_array(out_ptr, n, output_begin);

    if (LOGICAL_VALUE(normalize_flag)) {
      normalize(out_ptr, n, 100, output_begin);
    }
  }

  UNPROTECT(protect_count);
  return result;
}
