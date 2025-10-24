// interface to ta_CDLEVENINGSTAR.c
//
// Description
//   Evening Star bearish reversal detector using TA-Lib's CDLEVENINGSTAR.
//   Supports user-specified penetration.
//
// Parameters
//   open, high, low, close : numeric vectors (same length)
//   penetration            : numeric scalar double in [0,1] (typical 0.3)
//   normalize_flag         : logical scalar; TRUE scales {-100,0,100} to
//   {-1,0,1}
//
// Returns
//   Integer vector length n with {-100, 0, 100}. Bearish pattern.
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
SEXP impl_ta_CDLEVENINGSTAR(
  SEXP open,
  SEXP high,
  SEXP low,
  SEXP close,
  SEXP penetration,
  SEXP normalize_flag) {
  // clang-format on

  int protect_count = 0;

  const int n = LENGTH(open);
  const double *restrict open_ptr = REAL(open);
  const double *restrict high_ptr = REAL(high);
  const double *restrict low_ptr = REAL(low);
  const double *restrict close_ptr = REAL(close);

  const double penetration_value = REAL(penetration)[0];

  SEXP result = PROTECT(allocVector(INTSXP, n));
  protect_count++;
  int *restrict out_ptr = INTEGER(result);

  const int minimum_lookback = TA_CDLEVENINGSTAR_Lookback(penetration_value);

  if (n < minimum_lookback) {
    Rf_warning("Input length (%d) is smaller than required lookback (%d).", n,
               minimum_lookback);
    for (int i = 0; i < n; ++i)
      out_ptr[i] = NA_INTEGER;

  } else {
    int output_begin = 0;
    int output_count = 0;

    // clang-format off
    TA_RetCode return_code = TA_CDLEVENINGSTAR(
      /*startIdx*/ 0,
      /*endIdx  */ n - 1,
      /*inOpen  */ open_ptr,
      /*inHigh  */ high_ptr,
      /*inLow   */ low_ptr,
      /*inClose */ close_ptr,
      /*optInPen*/ penetration_value,
      /*outBeg  */ &output_begin,
      /*outNb   */ &output_count,
      /*outInt  */ out_ptr
    );
    // clang-format on

    if (return_code != TA_SUCCESS) {
      UNPROTECT(protect_count);
      Rf_error("TA_CDLEVENINGSTAR failed: return code %d", return_code);
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
