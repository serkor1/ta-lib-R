// interface to ta_CDLSEPARATINGLINES.c
//
// Description
// R C-interface for TA-Lib's CDLSEPARATINGLINES. Detects Separating Lines.
//
// Parameters
// open, high, low, close: numeric vectors, equal length
// normalize_flag: logical; if TRUE divide outputs by 100 in-place
//
// Returns
// Integer vector length n. +100 bullish continuation (bullish separating
// lines), -100 bearish continuation (bearish separating lines), 0 otherwise. If
// normalized: +1, -1, 0. :contentReference[oaicite:11]{index=11}

#include "R_ext/Arith.h"
#include "Rinternals.h"
#include "lib.h"
#include "normalize.h"
#include "shift.h"
#include <ta_libc.h>

SEXP impl_ta_CDLSEPARATINGLINES(SEXP open, SEXP high, SEXP low, SEXP close,
                                SEXP normalize_flag) {

  int protect_count = 0;

  const int n = LENGTH(open);
  const double *restrict open_ptr = REAL(open);
  const double *restrict high_ptr = REAL(high);
  const double *restrict low_ptr = REAL(low);
  const double *restrict close_ptr = REAL(close);

  SEXP result = PROTECT(allocVector(INTSXP, n));
  protect_count++;
  int *restrict out_ptr = INTEGER(result);

  const int minimum_lookback = TA_CDLSEPARATINGLINES_Lookback();

  if (n < minimum_lookback) {
    Rf_warning("Input length (%d) < lookback (%d).", n, minimum_lookback);
    for (int i = 0; i < n; ++i)
      out_ptr[i] = NA_INTEGER;
  } else {
    int output_begin_index = 0, output_number_of_elements = 0;

    // clang-format off
    TA_RetCode return_code = TA_CDLSEPARATINGLINES(
      /*startIdx*/ 0,
      /*endIdx  */ n - 1,
      /*inOpen  */ open_ptr,
      /*inHigh  */ high_ptr,
      /*inLow   */ low_ptr,
      /*inClose */ close_ptr,
      /*outBeg  */ &output_begin_index,
      /*outNb   */ &output_number_of_elements,
      /*outInt  */ out_ptr
    );
    // clang-format on

    if (return_code != TA_SUCCESS) {
      UNPROTECT(protect_count);
      Rf_error("TA_CDLSEPARATINGLINES failed: %d", return_code);
    }

    shift_array(out_ptr, n, output_begin_index);
    if (LOGICAL_VALUE(normalize_flag))
      normalize(out_ptr, n, 100, output_begin_index);
  }

  UNPROTECT(protect_count);
  return result;
}
