// interface to ta_CDLMATCHINGLOW.c
//
// Description
// Identifies the Matching Low candlestick pattern.
// Values are {-100, 0, 100}; optionally normalized.
//
// Parameters
// open, high, low, close: numeric vectors
// normalize_flag: logical
//
// Returns
// Integer vector length n. Matching Low is generally bullish reversal.

#include "R_ext/Arith.h"
#include "Rdefines.h"
#include "Rinternals.h"
#include "lib.h"
#include "normalize.h"
#include "shift.h"
#include <stdbool.h>
#include <ta_libc.h>

// clang-format off
SEXP impl_ta_CDLMATCHINGLOW(
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

  const int minimum_lookback = TA_CDLMATCHINGLOW_Lookback();

  if (n < minimum_lookback) {
    Rf_warning("Input length (%d) is smaller than required lookback (%d).", n,
               minimum_lookback);
    for (int i = 0; i < n; ++i)
      out_ptr[i] = NA_INTEGER;
  } else {
    int out_begin_index = 0, out_number_of_elements = 0;

    // clang-format off
    TA_RetCode return_code = TA_CDLMATCHINGLOW(
      /*startIdx*/ 0,
      /*endIdx  */ n - 1,
      /*inOpen  */ open_ptr,
      /*inHigh  */ high_ptr,
      /*inLow   */ low_ptr,
      /*inClose */ close_ptr,
      /*outBeg  */ &out_begin_index,
      /*outNb   */ &out_number_of_elements,
      /*outInt  */ out_ptr
    );
    // clang-format on

    if (return_code != TA_SUCCESS) {
      UNPROTECT(protect_count);
      Rf_error("TA_CDLMATCHINGLOW failed: %d", return_code);
    }

    shift_array(out_ptr, n, out_begin_index);
    if (Rf_asLogical(normalize_flag))
      normalize(out_ptr, n, 100, out_begin_index);
  }

  UNPROTECT(protect_count);
  return result;
}
